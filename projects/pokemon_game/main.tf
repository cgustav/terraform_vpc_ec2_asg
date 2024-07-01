# Main Terraform configuration for Pokemon Online Game AWS Infrastructure

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

# Reference to other configuration files
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

module "ec2" {
  source = "./modules/ec2"
  #   public_subnet_ids     = module.vpc.public_subnet_ids
  #   private_subnet_ids    = module.vpc.private_subnet_ids
  #   target_group_arn      = module.elb.target_group_arn
  #   web_security_group_id = module.security.web_security_group_id

  #   WEB SERVER CONFIG 
  server_configs = [
    {
      name               = "web"
      instance_type      = "t3.micro"
      image_id           = null # Use the default Amazon Linux 2 AMI
      security_group_ids = [module.security.web_security_group_id, module.security.internal_security_group_id]
      desired_capacity   = 2
      min_size           = 1
      max_size           = 4
      user_data          = <<-EOF
                          #!/bin/bash
                          # Update the system 
                          yum update -y
                          #   yum install -y httpd
                          #   systemctl start httpd
                          #   systemctl enable httpd

                          su - ec2-user -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash'
                          su - ec2-user -c '. ~/.nvm/nvm.sh'

                          #   nvm install --lts
                          su - ec2-user -c "nvm install v16.14.0"
                          su - ec2-user -c "nvm use v16.14.0"
                          su - ec2-user -c "nvm --version"
                          su - ec2-user -c "node --version"

                          # Install Git
                          yum install -y git
                          
                          git clone https://github.com/cgustav/pokeapp.git /home/ec2-user/pokeapp

                          # Build production app
                          echo "Preparing Frontend production app"  
                          cat > /home/ec2-user/pokeapp/pokemon-front/.env << 'INNEREOF'
                          REACT_APP_API_URL=https://poke.zozlabs.cloud:3001
                          INNEREOF

                          # Ensure ec2-user is pokeapp dir owner
                          chown -R ec2-user:ec2-user /home/ec2-user/pokeapp
                          chmod -R 775 /home/ec2-user/pokeapp

                          echo "Building Frontend production app"

                          su - ec2-user -c 'cd /home/ec2-user/pokeapp/pokemon-front && npm install && npm run build'
                          echo "Check application source code is ready: "
                          ls -l /home/ec2-user/pokeapp/pokemon-front/build

                          # Install NGINX
                          echo "Installing NGINX... "
                          amazon-linux-extras install nginx1 -y
                          systemctl start nginx && systemctl enable nginx
                          echo "Check NGINX service status: "
                          systemctl status nginx
                          echo "Check NGINX version: "
                          nginx -v

                          # Migrating build files into NGINX statics
                          echo "Migrating build files into NGINX statics"
                          cp -R /home/ec2-user/pokeapp/pokemon-front/build/* /usr/share/nginx/html
                          echo "Ensure NGINX production statics!"
                          ls -l /usr/share/nginx/html

                          # Setup NGINX statics
                          chmod 2775 /usr/share/nginx/html 
                          find /usr/share/nginx/html -type d -exec chmod 2775 {} \;
                          find /usr/share/nginx/html -type f -exec chmod 0664 {} \;
                          #   echo "<h3> Welcome to my NGINX web server! User data instillation was a SUCCESS! </h3>" > /usr/share/nginx/html/index.html

                          #   cp -R /home/ec2-user/pokeapp/pokemon-front/build/* /var/www/html/
                          #   systemctl restart httpd

                          echo "Restarting NGINX server... "  
                          systemctl restart nginx

                          echo "Installing PM2"
                          su - ec2-user -c 'npm install pm2@latest -g'
                          env PATH=$PATH:/home/ec2-user/.nvm/versions/node/v18.18.2/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

                          echo "Preparing Backend API..."

                          # Create Backend API .env file
                          cat > /home/ec2-user/pokeapp/pokemon-backend/.env << 'INNEREOF'
                          MYSQL_USER=consumer
                          MYSQL_PASSWORD=consumer
                          MYSQL_DATABASE=pokemon_game
                          JWT_SECRET=RKp7Lhd96xb&8KkcY
                          
                          # UPDATE YOUR DB ADDRESS HERE
                          # TODO: CHANGE TO NLB INTERNAL DNS
                          DB_HOST=69.12.227.126
                          INNEREOF

                          # Ensure .env access permissions
                          chown ec2-user:ec2-user /home/ec2-user/pokeapp/pokemon-backend/.env
                          chmod 775 /home/ec2-user/pokeapp/pokemon-backend/.env
                         
                          echo "Setup and serve Backend API via PM2: "
                          su - ec2-user -c 'cd /home/ec2-user/pokeapp/pokemon-backend && npm install && pm2 start app.js'

                          # DONE  

                          EOF

      target_group_arns = [module.elb.frontend_target_group_arn, module.elb.backend_target_group_arn]
      subnet_ids        = module.vpc.public_subnet_ids
    },

    # DATABASE (MYSQL) SERVER CONFIG 
    {
      name               = "database"
      instance_type      = "t3.small"
      image_id           = null # Use the default Amazon Linux 2 AMI
      security_group_ids = [module.security.db_security_group_id, module.security.internal_security_group_id]
      desired_capacity   = 1
      min_size           = 1
      max_size           = 2
      user_data          = <<-EOF
                          #!/bin/bash
                          # Update the system
                          yum update -y

                          # Install MariaDB
                          yum install -y mariadb-server

                          # Start MySQL service
                          systemctl start mariadb
                          systemctl enable mariadb

                          # Secure DB installation via
                          # amazon-linux-extras install -y mysql8.0

                          # Secure MySQL installation
                          cat > mysql_secure_installation.sql <<EOF2
                          # Make sure that NOBODY can access the server without a password
                          UPDATE mysql.user SET Password=PASSWORD('rootpw') WHERE User='root';

                          # Kill the anonymous users
                          DELETE FROM mysql.user WHERE User='';

                          # disallow remote login for root
                          DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

                          # Kill off the demo database
                          DROP DATABASE IF EXISTS test;
                          DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

                          # Grant permissions to localhost exclusive user
                          CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
                          GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost' WITH GRANT OPTION;

                          # Grant permissions to remote user
                          CREATE USER 'consumer'@'%' IDENTIFIED BY 'consumer';
                          GRANT ALL PRIVILEGES ON *.* TO 'consumer'@'%' WITH GRANT OPTION;

                          # Make our changes take effect
                          FLUSH PRIVILEGES;
                          EOF2
                        
                          # Execute custom secure db installation   
                          mysql -uroot  <mysql_secure_installation.sql

                          cat > init_db.sql <<EOF3
                          # Create DB
                          CREATE DATABASE IF NOT EXISTS pokemon_game;
                          USE pokemon_game;

                          # Create users table
                          CREATE TABLE IF NOT EXISTS users (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          email VARCHAR(255) NOT NULL UNIQUE,
                          name VARCHAR(255) NOT NULL,
                          date_of_birth DATE NOT NULL,
                          password VARCHAR(255) NOT NULL
                          );

                          # Create pokemon table
                          CREATE TABLE IF NOT EXISTS pokemon (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          pokedex_id INT NOT NULL UNIQUE,
                          name VARCHAR(255) NOT NULL,
                          type VARCHAR(50) NOT NULL,
                          base_experience INT NOT NULL
                          );

                          # Create user/pokemon relationship table
                          CREATE TABLE IF NOT EXISTS user_pokemon (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          user_id INT NOT NULL,
                          pokemon_id INT NOT NULL,
                          nickname VARCHAR(255),
                          level INT DEFAULT 1,
                          experience INT DEFAULT 0,
                          FOREIGN KEY (user_id) REFERENCES users(id),
                          FOREIGN KEY (pokemon_id) REFERENCES pokemon(id)
                          );

                          # Create pokemon battle history
                          CREATE TABLE IF NOT EXISTS battle_history (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          user_id INT NOT NULL,
                          pokemon_id INT NOT NULL,
                          pokemon_pokedex_id INT NOT NULL,
                          experience_gained INT NOT NULL,
                          remaining_hp INT NOT NULL,
                          enemy_pokemon_pokedex_id INT NOT NULL,
                          enemy_pokemon_name VARCHAR(255) NOT NULL,
                          user_won BOOLEAN NOT NULL,
                          battle_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          FOREIGN KEY (user_id) REFERENCES users(id),
                          FOREIGN KEY (pokemon_id) REFERENCES pokemon(id)
                          );

                          # Create indexes
                          CREATE INDEX idx_email ON users(email);
                          CREATE INDEX idx_user_pokemon ON user_pokemon(user_id, pokemon_id);
                          CREATE INDEX idx_battle_user ON battle_history(user_id);
                          CREATE INDEX idx_battle_enemy ON battle_history(enemy_pokemon_pokedex_id);
                          CREATE INDEX idx_battle_date ON battle_history(battle_date);
                          EOF3
                          
                          # Execute InitDB Script
                          mysql -uroot -p"rootpw" <init_db.sql

                          # End script

                          EOF

      target_group_arns = []
      subnet_ids        = module.vpc.private_subnet_ids
      #   TEST ONLY 
      #   subnet_ids = module.vpc.public_subnet_ids

    }
  ]
}
