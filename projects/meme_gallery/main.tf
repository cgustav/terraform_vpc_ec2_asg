# Main Terraform configuration for Meme Gallery

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  # COMMENT THIS IF YOU DONT WANT TO USE S3 BACKEND 
  backend "s3" {}

}

provider "aws" {}

data "aws_caller_identity" "current" {

}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security" {
  source   = "./modules/security"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
}

module "elb" {
  source                = "./modules/elb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  lb_certificate_arn    = var.ssl_certificate_arn
}

module "route53" {
  source       = "./modules/route53"
  domain_name  = var.domain_name
  subdomain    = var.subdomain
  alb_dns_name = module.elb.load_balancer_dns_name
  alb_zone_id  = module.elb.load_balancer_zone_id
  create_zone  = var.create_route53_zone
}

resource "random_password" "rds_password" {
  length           = 24
  special          = true                 # by default
  override_special = "!#$&*()-=+[]{}<>:?" # all tf special characters without '/', '@', '"', ' ' (rds requirement)
}

data "template_file" "init_script" {
  template = file("${path.module}/data/initdb.sql")
}

module "rds" {
  source                 = "./modules/rds"
  allocated_storage      = var.rds_allocated_storage
  max_connections        = var.rds_max_connections
  buffer_pool_size       = var.rds_buffer_pool_size
  storage_type           = var.rds_storage_type
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = random_password.rds_password.result
  parameter_group_name   = var.rds_parameter_group_name
  vpc_security_group_ids = [module.security.internal_security_group_id, module.security.db_security_group_id]
  db_subnet_group_name   = module.vpc.rds_subnet_group_name
  subnet_ids             = module.vpc.private_subnet_ids
  # init_script            = data.template_file.init_script.rendered
  tags = {
    Name        = "${var.project}-RDS"
    Environment = var.environment
    Project     = var.project
  }
}



# Create buckets

module "s3" {
  source = "./modules/s3"

  buckets = [

    /*
      Bucket for lambda layers storage
      ----------------------------------------

      This is intended to store node_modules
      shared dependencies, this way we avoid
      using lambda storage quota and managing
      multiple dependencies separated from our
      source code in an optimal and 
      cost-efficient way.

      */

    # {
    #   name       = "meme-gallery-lambda-layers-storage",
    #   versioning = false,
    #   cors_rules = []
    #   policy = jsonencode({
    #     "Version" : "2012-10-17",
    #     "Statement" : [
    #       {
    #         "Effect" : "Allow",
    #         "Action" : [
    #           "s3:GetObject",
    #           "s3:ListBucket"
    #         ],
    #         "Resource" : [
    #           "arn:aws:s3:::meme-gallery-lambda-layers-storage",
    #           "arn:aws:s3:::meme-gallery-lambda-layers-storage/*"
    #         ],
    #         "Principal" : "*",
    #         "Condition" : {
    #           "StringLike" : {
    #             "aws:PrincipalArn" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*exec_role*"
    #           }
    #         }
    #       }
    #     ]
    #     }
    #   )
    # },

    /*
      Bucket for RDS automatic backup storage
      this is intended to hold static files
      like .sql DUMP DATA
      ----------------------------------------

      This bucket should be private and only 
      accesible from lambdas responsible to
      crate automatic backups.

      This practice is not recommended, consider
      using RDS backup native feature instead.
    */
    #  TODO
    # {
    #   name       = "meme-gallery-rds-static-backup",
    #   versioning = false,
    #   cors_rules = [
    #     {
    #       allowed_headers = ["*"]
    #       allowed_methods = ["*"]
    #       allowed_origins = ["*"]
    #       expose_headers  = ["*"]
    #       max_age_seconds = 100000
    #     }
    #   ],
    #   policy = jsonencode({
    #     "Version" : "2012-10-17",
    #     "Statement" : [
    #       {
    #         "Effect" : "Allow",
    #         "Action" : [
    #           "s3:PutObject",
    #           "s3:GetObject",
    #           "s3:DeleteObject",
    #           "s3:ListBucket"
    #         ],
    #         "Resource" : [
    #           "arn:aws:s3:::meme-gallery-rds-static-backup",
    #           "arn:aws:s3:::meme-gallery-rds-static-backup/*"
    #         ],
    #         "Principal" : "*",
    #         "Condition" : {
    #           "StringLike" : {
    #             "aws:PrincipalArn" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*exec_role*"
    #           }
    #         }
    #       }
    #     ]
    #     }
    #   )
    # },



    /*
      Bucket for web application storage (memes)
      ----------------------------------------

      This bucket is responsible to store all
      media files from the meme gallery.

      Ensure to make this bucket public with restrictions
      (ej, enable GET API Operations for everyone and
      enable PUT Operations only for the role arn associated
      with your frontend S3 API/SDK consumer)

      */
    {
      name       = "${var.public_assets_bucket_name}",
      versioning = false,
      bucket_acl = "public-read"
      cors_rules = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "HEAD", "PUT"]
          allowed_origins = ["*"]
          expose_headers  = ["ETag"]
          max_age_seconds = 3000
        }
      ],
      policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListBucket"

            ],
            "Resource" : ["arn:aws:s3:::${var.public_assets_bucket_name}", "arn:aws:s3:::${var.public_assets_bucket_name}/*"],
            "Principal" : "*",
            # "Condition" : {
            #   "StringEquals" : {
            #     "s3:x-amz-acl" : "public-read"
            #   }
            # }
          }
        ]
        }
      )
    },


  ]
}

module "iam" {
  source    = "./modules/iam"
  user_name = var.public_assets_bucket_manager_username
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListObject",
        ]
        Resource = "arn:aws:s3:::${var.public_assets_bucket_name}/*"
      }
    ]
  })
}


# Create DB SSM Secrets
module "ssm" {
  source = "./modules/ssm"

  db_name_name  = "db_name"
  db_name_value = "meme_gallery"

  db_endpoint_name  = "db_endpoint"
  db_endpoint_value = module.rds.db_instance_endpoint

  db_username_name  = "db_username"
  db_username_value = module.rds.db_instance_username

  db_password_name  = "db_password"
  db_password_value = module.rds.db_instance_password

  frontend_dns_name  = "frontend_dns"
  frontend_dns_value = "https://${module.route53.route53_record_fqdn}"

  api_address_name  = "api_address"
  api_address_value = "https://${module.route53.route53_record_fqdn}:3001"

  s3_bucket_region_name  = "public_bucket_region_name"
  s3_bucket_region_value = module.s3.buckets[0].region

  s3_bucket_name_name  = "public_bucket_name"
  s3_bucket_name_value = module.s3.buckets[0].bucket

  s3_bucket_key_id_name  = "public_key_id"
  s3_bucket_key_id_value = module.iam.access_key

  s3_bucket_secret_key_name  = "public_secret_key"
  s3_bucket_secret_key_value = module.iam.secret_key

}

# data "archive_file" "rds_layer_version" {
#   type        = "zip"
#   source_file = "./data/lambda/layers/rds-related/"
#   output_path = "./data/lambda/layers/rds-related.zip"
# }

# Executing pack layers command
resource "null_resource" "generate_layer" {
  provisioner "local-exec" {
    command = "sh ./pack-layers.sh"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

module "lambda_layers" {
  source = "./modules/lambda_layers"
  layers_spec = [{
    layer_name  = "rds-related"
    description = "Implement this layers in those lambdas that performs tasks on RDS."

    file_name           = "${path.module}/data/layers/rds-related.zip"
    source_code_hash    = filebase64sha256("${path.module}/data/layers/rds-related.zip")
    compatible_runtimes = ["nodejs14.x", "nodejs16.x", "nodejs18.x"]
    # deprecated params 
    # s3_bucket_id        = module.s3.buckets[0].id
    # s3_key              = "rds-related.zip"
    # depends_on          = [module.s3.buckets[0].id]
  }]

}

# Fetch our file from the local file system
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./data/lambda/rds-bootstrap-function/index.js"
  output_path = "./data/lambda/rds-bootstrap-function/index.zip"
}



# module "lambda" {
#   source = "./modules/lambda"
# lambda_functions = [
#   # {
#   #   function_name = "backup_rds"
#   #   handler       = "index.handler"
#   #   runtime       = "nodejs14.x"
#   #   source_path   = "path/to/backup_rds.zip"
#   #   environment_variables = {
#   #     RDS_INSTANCE_ID = aws_db_instance.mydb.id
#   #     S3_BUCKET       = "my-backup-bucket"
#   #   }
#   #   subnet_ids         = module.vpc.public_subnet_ids
#   #   security_group_ids = [aws_security_group.lambda_sg.id]
#   #   iam_policy_path    = "path/to/backup_rds_policy.json"
#   # },
#   {
#     function_name    = "rds_bootstraper"
#     handler          = "index.handler"
#     runtime          = "nodejs18.x"
#     layers           = module.lambda_layers.layer_arns,
#     source_path      = data.archive_file.lambda.output_path
#     source_code_hash = data.archive_file.lambda.output_base64sha256
#     environment_variables = {
#       DB_ENDPOINT_PARAM = module.ssm.db_endpoint_name,
#       DB_NAME_PARAM     = module.ssm.db_name_name,
#       DB_USERNAME_PARAM = module.ssm.db_username_name,
#       DB_PASSWORD_PARAM = module.ssm.db_password_name,
#       SQL_SCRIPT_URL    = "https://raw.githubusercontent.com/cgustav/meme-gallery/master/data/initdb.sql"
#     }
#     subnet_ids         = module.vpc.public_subnet_ids
#     security_group_ids = [module.security.internal_security_group_id]
#     iam_policy = jsonencode({
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Effect" : "Allow",
#           "Action" : [
#             "logs:CreateLogGroup",
#             "logs:CreateLogStream",
#             "logs:PutLogEvents"
#           ],
#           "Resource" : "arn:aws:logs:*:*:*"
#         },
#         {
#           "Effect" : "Allow",
#           "Action" : ["secretsmanager:GetSecretValue"],
#           "Resource" : "*"
#         },

#         {
#           "Effect" : "Allow",
#           "Action" : ["rds:DescribeDBInstances"],
#           "Resource" : "*"
#         },

#         {
#           "Sid" : "AllowEIPForLambdas",
#           "Effect" : "Allow",
#           "Action" : [
#             "ec2:DescribeNetworkInterfaces",
#             "ec2:CreateNetworkInterface",
#             "ec2:DeleteNetworkInterface",
#             "ec2:DescribeInstances",
#             "ec2:AttachNetworkInterface"
#           ],
#           "Resource" : "*"
#         }
#       ]
#       }
#     )
#     log_retention_in_days = 14
#   }
# ]
# }

# TODO
# Execute your SQL script once your RDS instance and
# bootstrapper function were fully deployed
# resource "aws_lambda_invocation" "bootstrapper_execution" {
#   function_name = module.lambda.lambda_function_names[0]
#   input         = jsonencode({})
#   depends_on    = [module.lambda, module.rds]
# }




module "ec2" {
  source = "./modules/ec2"
  server_configs = [

    /*
      WEB SERVER CONFIGURATION
      Purpose       : Serve web meme gallery statics
      Is public     : true
      Exposed ports : 80, 443, 3001
      SSL scheme    : ACM
      Defaut AMI    : Ubuntu
    */
    {
      name               = "web"
      instance_type      = "t3.micro"
      image_id           = null # Use the default Module AMI
      security_group_ids = [module.security.web_security_group_id, module.security.internal_security_group_id]
      desired_capacity   = 1
      min_size           = 1
      max_size           = 2
      user_data          = <<-EOF
                          #!/bin/bash
                          # UPDATE PACKAGE MANAGER
                          apt update -y --fix-missing

                          # MYSQL CLIENT & GIT
                          apt install -y mysql-client-core-8.0 git

                          # INSTALL AWS CLI
                          sudo snap install aws-cli --classic
                          
                          # INSTALL AND CONFIGURE NODEJS SCRIPT
                          cat > /tmp/install-node.sh <<EOF2
                          echo "Setting up NodeJS Environment"
                          
                          # Fork repo, review this
                          curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
                          echo 'export NVM_DIR="/home/ubuntu/.nvm"' >> /home/ubuntu/.bashrc
                          echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/ubuntu/.bashrc

                          # Dot source the files to ensure that variables are available within the current shell
                          . /home/ubuntu/.nvm/nvm.sh
                          . /home/ubuntu/.profile
                          . /home/ubuntu/.bashrc

                          # Install NVM, NPM, Node.JS & Grunt
                          nvm install --lts
                          nvm ls

                          # Install subdependencies
                          npm install pm2@latest -g

                          EOF2

                          # Execute NodeJS setup configuration as non root user
                          chown ubuntu:ubuntu /tmp/install-node.sh && chmod a+x /tmp/install-node.sh
                          sleep 1; su - ubuntu -c "source /tmp/install-node.sh"

                          # TODO SOURCE
                          echo "Enhance installation: "
                          nvm version 

                          cat > /tmp/install-apps.sh <<EOF3
                          cd /home/ubuntu

                          echo 'export NVM_DIR="/home/ubuntu/.nvm"' >> /home/ubuntu/.bashrc
                          echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/ubuntu/.bashrc

                          # Dot source the files to ensure that variables are available within the current shell
                          . /home/ubuntu/.nvm/nvm.sh
                          . /home/ubuntu/.profile
                          . /home/ubuntu/.bashrc

                          echo "Ensure nvm & node inside install apps script..."
                          node --version
                          npm --version

                          git clone https://github.com/cgustav/meme-gallery.git

                          # RETRIEVE PARAMETERS FROM SSM - FRONTEND WEB SERVICE
                          PUBLIC_DNS=$(aws ssm get-parameter --name ${module.ssm.frontend_dns_name} --region ${var.aws_region} --with-decryption --query 'Parameter.Value' --output text)
                          API_URL=$(aws ssm get-parameter --name ${module.ssm.api_address_name} --region ${var.aws_region} --with-decryption --query 'Parameter.Value' --output text)
                          BUCKET_REGION=$(aws ssm get-parameter --name ${module.ssm.s3_bucket_region_name} --region ${var.aws_region} --with-decryption --query 'Parameter.Value' --output text)
                          BUCKET_NAME=$(aws ssm get-parameter --name ${module.ssm.s3_bucket_name_name} --region ${var.aws_region} --with-decryption --query 'Parameter.Value' --output text)
                          BUCKET_KEY_ID=$(aws ssm get-parameter --name ${module.ssm.s3_bucket_key_id_name} --region ${var.aws_region} --with-decryption --query 'Parameter.Value' --output text)
                          BUCKET_SECRET_ACCESS_KEY=$(aws ssm get-parameter --name ${module.ssm.s3_bucket_secret_key_name} --region ${var.aws_region} --with-decryption --query 'Parameter.Value' --output text)
                          
                          # EXPORT PARAMETERS AS ENVIRONMENT VARIABLES
                          # echo "export PUBLIC_DNS=memes.zozlabs.cloud" >> /etc/environment
                          sudo sh -c 'echo "export PUBLIC_DNS=$PUBLIC_DNS" >> /etc/environment'

                          echo "NEXT_PUBLIC_API_URL=https://memes.zozlabs.cloud:3001" >> ./meme-gallery/meme-gallery-frontend/.env.local
                          echo "NEXT_PUBLIC_AWS_REGION=us-east-1" >> ./meme-gallery/meme-gallery-frontend/.env.local
                          echo "NEXT_PUBLIC_AWS_ACCESS_KEY_ID=AKIAXR7QNNWVXRY6PPWB" >> ./meme-gallery/meme-gallery-frontend/.env.local
                          echo "NEXT_PUBLIC_AWS_SECRET_ACCESS_KEY=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" >> ./meme-gallery/meme-gallery-frontend/.env.local
                          echo "NEXT_PUBLIC_AWS_S3_BUCKET_NAME=meme-gallery-useast1-mk1899gr" >> ./meme-gallery/meme-gallery-frontend/.env.local

                          # RETRIEVE PARAMETERS FROM SSM - BACKEND API SERVICE
                          DB_HOST=$(aws ssm get-parameter --name ${module.ssm.db_endpoint_name} --region ${var.aws_region} --query 'Parameter.Value' --output text)
                          DB_USERNAME=$(aws ssm get-parameter --name ${module.ssm.db_username_name} --region ${var.aws_region} --query 'Parameter.Value' --output text)
                          DB_PASSWORD=$(aws ssm get-parameter --name ${module.ssm.db_password_name} --region ${var.aws_region} --with-decryption --query 'Parameter.Value' --output text)
                          DB_NAME=$(aws ssm get-parameter --name ${module.ssm.db_name_name} --region ${var.aws_region} --with-decryption --query 'Parameter.Value' --output text)
                          
                          # EXPORT PARAMETERS AS ENVIRONMENT VARIABLES
                          echo "DB_HOST=instance-gallerydb.clqwoo0a4n72.us-east-1.rds.amazonaws.com" >> ./meme-gallery/api/.env
                          echo "DB_USER=AdminCross" >> ./meme-gallery/api/.env
                          echo "DB_PASSWORD=[]Ml19u9N?$D6CjDP5KN7zQE" >> ./meme-gallery/api/.env
                          echo "DB_NAME=meme_gallery" >> ./meme-gallery/api/.env

                          sudo sh -c 'echo "export DB_HOST=instance-gallerydb.clqwoo0a4n72.us-east-1.rds.amazonaws.com" >> /etc/environment'
                          sudo sh -c 'echo "export DB_USER=AdminCross" >> /etc/environment'
                          sudo sh -c 'echo "export DB_PASSWORD=[]Ml19u9N?$D6CjDP5KN7zQE" >> /etc/environment'
                          sudo sh -c 'echo "export DB_NAME=meme_gallery" >> /etc/environment'

                          # echo "export DB_ENDPOINT=$DB_ENDPOINT" >> /etc/environment
                          # echo "export DB_USERNAME=$DB_USERNAME" >> /etc/environment
                          # echo "export DB_PASSWORD=$DB_PASSWORD" >> /etc/environment

                          # SETUP AND SERVE FRONTEND WEB APP
                          cd ./meme-gallery/meme-gallery-frontend
                          npm install
                          npm run build
                          
                          pm2 start npm --name "meme-gallery-frontend" -- start
                          pm2 save
                          pm2 startup

                          # SETUP AND SERVE BACKEND API SERVICE
                          cd ../api
                          npm install

                          pm2 start npm --name "meme-gallery-api" -- start
                          pm2 save
                          pm2 startup

                          cd ../..

                          EOF3


                          #RUN COMMAND 
                          chown ubuntu:ubuntu /tmp/install-apps.sh && chmod a+x /tmp/install-apps.sh
                          sleep 1; su - ubuntu -c "source /tmp/install-apps.sh"

                          # INSTALL, START and ENABLE NGINX
                          apt install -y nginx
                          systemctl start nginx
                          systemctl enable nginx

                          # CONFIGURE REVERSE PROXY
                          tee /etc/nginx/conf.d/meme-gallery-frontend.conf > /dev/null << 'EOF4'
                          server {
                            listen 80;
                            server_name memes.zozlabs.cloud;
                            location / {
                              proxy_pass http://localhost:3000;
                              proxy_http_version 1.1;
                              proxy_set_header Upgrade \$http_upgrade;
                              proxy_set_header Connection 'upgrade';
                              proxy_set_header Host \$host;
                              proxy_cache_bypass \$http_upgrade;
                            }
                          }
                          EOF4

                          # echo "ABOUT TO CONFIGURE NGINX CONF WITH PUBLIC DNS: $PUBLIC_DNS"
                          # sed -i "s/server_name your-domain.com;/server_name $PUBLIC_DNS;/" /etc/nginx/conf.d/meme-gallery-frontend.conf
                         
                          echo "ABOUT TO TEST NGINX CONFIGS"
                          nginx -t

                          systemctl restart nginx

                          # CHANGE FILE PERMISSION TO PERMIT MODIFICATION OF DEFAULT WEB FILE
                          # chmod 0777 /var/www/html/index.nginx-debian.html

                          # MODIFY DEFAULT WEB DOCUMENT
                          # echo "<html><h1>Hello from your web server!</h1></html>" > /var/www/html/index.nginx-debian.html

                          # RESTART NGINX
                          # systemctl start nginx

                          EOF

      target_group_arns = [module.elb.frontend_target_group_arn, module.elb.backend_target_group_arn]
      subnet_ids        = module.vpc.public_subnet_ids
  }]
}
