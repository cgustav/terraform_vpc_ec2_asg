provider "aws" {
  region = "us-east-1"
  profile = "personal-tf"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Config VPC
resource "aws_vpc" "main" {
  cidr_block = "69.12.10.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "PracticeVPC"
    Environment = "Sandbox"
    Type = "VPC"
  }
}


# Config Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "PracticeInternetGateway"
    Environment = "Sandbox"
    Type = "InternetGateway"
  }
}

# Config subnets 

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  # cidr_block        = "69.12.10.0/24"
  # 62 direcciones disponibles
  cidr_block        = "69.12.10.0/26"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Subnet privada (no necesaria para este ejercicio)
# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.1.30.0/24"

#   tags = {
#     Name = "PracticePrivateSubnet"
#     Environment = "Sandbox"
#   }
# }

# Config NAT 

# resource "aws_eip" "nat" {
# #   vpc = true
#   depends_on = [aws_internet_gateway.gw]
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public_subnet.id

#   tags = {
#     Name = "PracticeNATGateway"
#     Type = "NAT"
#     Environment = "Sandbox"
#   }
# }


# Config Route Tables

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "PracticePublicRouteTable"
    Type = "RouteTable"
    Environment = "Sandbox"
  }
}

resource "aws_route_table_association" "public_route_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Route table privada (no necesaria para este ejercicio)
# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }

#   tags = {
#     Name = "PrivateRouteTable"
#     Type = "RouteTable"
#     Environment = "Sandbox"
#   }
# }

# resource "aws_route_table_association" "private_route_assoc" {
#   subnet_id      = aws_subnet.private_subnet.id
#   route_table_id = aws_route_table.private_route_table.id
# }

# ----------------------------------------------
# Configuración de roles y políticas IAM (EC2)

resource "aws_iam_role" "ec2_s3_role" {
  name = "EC2S3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# NOTE: DEPRECATED TEMPORARILY
# module "s3_buckets" {
#   source              = "./modules/s3_buckets"
#   bucket_name         = "website-sfiles-xfe1010"
#   environment         = "Sandbox"
#   ec2_role_arn        = aws_iam_role.ec2_s3_role.arn  # Asegúrate de que este recurso está correctamente definido y referenciado
#   paths_to_static_files = [
#         "sta_mu_comb",
#         # "sta_mu_illa",
#         "sta_mu_oval",
#         "sta_mu_puni"
#   ]
# }

resource "aws_iam_policy" "ec2_s3_access_policy" {
  name        = "EC2OptimalOperationPolicy"
  description = "Política de IAM para operación óptima de instancias EC2"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:ListBucket",
            "s3:ListBucketVersions",
        ],
        Resource = [
            "arn:aws:s3:::webstatics-pfma",
            "arn:aws:s3:::webstatics-pfma/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DeleteSnapshot"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.ec2_s3_access_policy.arn
}

# ----------------------------------------------
# Configuración de llaves criptográficas 
# para acceso remoto (PEM)

# Asegúrate de tener la llave pública en la ubicación 
# especificada o ajusta la ruta según sea necesario.

# Puedes generar la llave:
# Linux/Mac: 
# ssh-keygen -t rsa -b 2048 -f ./ec2_practice_key
# Windows:
# ssh-keygen -t rsa -b 2048 -f .\ec2_practice_key

resource "aws_key_pair" "ec2_auth" {
  key_name   = "ec2-key-pair"
  public_key = file("${path.module}/ec2_practice_key.pub")

  tags = {
    Name = "PracticeKeyPairs"
    Type = "AWSKeyPair"
    Environment = "Sandbox"
  }

}

# Instancia de Windows Server IIS
resource "aws_instance" "windows_iis_instance" {
  # Microsoft Windows Server 2022 Base (64-bit (x86))
  ami = "ami-0f496107db66676ff"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [ aws_security_group.instance_sg.id ]
  key_name      = aws_key_pair.ec2_auth.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data = <<-EOF
                <powershell>
                # Instalar el módulo AWS Tools for PowerShell
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
                Install-Module -Name AWS.Tools.Common -Force
                Install-Module -Name AWS.Tools.S3 -Force  # Instalar solo el módulo para S3 si solo necesitas S3

                # Instalar IIS
                Install-WindowsFeature -name Web-Server -IncludeManagementTools
                Set-Service -name W3SVC -startuptype Automatic

                # Configurar IIS para servir el sitio web
                # Import-Module WebAdministration
                # $sitePath = 'C:\inetpub\wwwroot\mysite'
                # if (-Not (Test-Path $sitePath)) {
                #     New-Item -Path $sitePath -Type Directory
                # }

                # Set-ItemProperty -Path 'IIS:\Sites\Default Web Site' -Name physicalPath -Value $sitePath

                # Descargar archivos estáticos de S3
                # $bucketName = "webstatics-pfma"
                # $localPath = "C:\inetpub\wwwroot\mysite"
                # $localPath = "C:\inetpub\wwwroot\mysite"
                # Alternativamente, puedes usar:
                $localPath = "$env:USERPROFILE\Desktop"
                Read-S3Object -BucketName $bucketName -Folder $localPath -KeyPrefix "sta_mu_oval/" -Region us-east-1

                # Permitir HTTP
                # New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
                # Permitir HTTPS
                # New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow

                # Configurar permisos para la cuenta de IIS
                # $accountName = "IIS_IUSRS"
                # icacls $sitePath /grant $accountName:`(OI`)`(CI`)R /T

                # Reiniciar IIS para aplicar configuraciones
                Restart-Service -Name W3SVC

                # Verificar que el sitio web esté en ejecución
                # Get-Website 

                </powershell>
                EOF

  tags = {
    Name = "WindowsIISInstance"
    Type = "VirtualMachine"
    Environment = "Sandbox"
  }
}

# Instancia de Ubuntu con LAMP
resource "aws_instance" "ubuntu_lamp_instance" {
  # ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230829
  ami = "ami-0408adfcef670a71e"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [ aws_security_group.instance_sg.id ]
  key_name      = aws_key_pair.ec2_auth.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data = <<-EOF
                #!/bin/bash
                # Actualiza todos los paquetes del sistema operativo
                apt-get update && apt-get upgrade -y
                apt-get install -y apache2
                apt-get install -y mysql-server
                apt-get install -y php libapache2-mod-php php-mysql php-cli php-gd php-xml

                # Instalar unzip, requerido para la instalación de AWS CLI v2
                apt-get install unzip -y

                # Descargar el paquete de instalación de AWS CLI v2
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                
                # Descomprimir el archivo de instalación
                unzip awscliv2.zip

                  # Ejecutar el script de instalación
                ./aws/install
                
                # Limpiar archivos de instalación
                rm awscliv2.zip
                rm -rf aws

                # Elimina contenido ya existente en el directorio /var/www/html
                rm -rf /var/www/html/*
                
                # Descargar contenido estático de S3
                aws s3 sync s3://webstatics-pfma/sta_mu_puni /var/www/html

                # Ajustar permisos
                chown -R www-data:www-data /var/www/html
                chmod -R 755 /var/www/html
                
                # Reiniciar Apache para aplicar configuraciones
                systemctl restart apache2

                EOF

  tags = {
    Name = "UbuntuLAMPInstance"
    Type = "VirtualMachine"
    Environment = "Sandbox"
  }
}

# Instancia de Amazon Linux 2023 con LAMP
resource "aws_instance" "amazon_linux_lamp_instance" {
  # amzn2-ami-hvm-2.0.20230404.0-x86_64-gp2
  ami = "ami-0d6927ccef429da8c"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [ aws_security_group.instance_sg.id ]
  key_name      = aws_key_pair.ec2_auth.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name


  user_data = <<-EOF
                #!/bin/bash
                yum install -y httpd mariadb-server php php-mysqlnd php-gd php-xml
                systemctl start httpd
                systemctl enable httpd
                systemctl start mariadb
                systemctl enable mariadb

                # Descargar contenido estático de S3
                # Ej: aws s3 sync s3://mi-bucket-name/mi-carpeta-estatica /var/www/html
                aws s3 sync s3://webstatics-pfma/sta_mu_comb /var/www/html
                
                # Ajustar permisos
                chown -R apache:apache /var/www/html
                chmod -R 755 /var/www/html
                
                # Reiniciar Apache para aplicar configuraciones
                systemctl restart httpd

                EOF

  tags = {
    Name = "AmazonLinuxLAMPInstance"
    Type = "VirtualMachine"
    Environment = "Sandbox"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2S3AccessProfile"
  role = aws_iam_role.ec2_s3_role.name
}

# Configuración de grupos de seguridad

resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id

  # Permitir acceso HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir acceso HTTP (Extra)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir acceso SSH y RDP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # Permitir acceso a FTP
  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir acceso RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "InstanceSecurityGroup"
    Type = "SecurityGroup"
    Environment = "Sandbox"
  }
}





            