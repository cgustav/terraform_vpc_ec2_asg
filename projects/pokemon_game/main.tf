# Main Terraform configuration for Pokemon Online Game AWS Infrastructure

# variable "region" {}
# variable "profile" {}
# variable "vpc_cidr" {}
# variable "public_subnet_cidrs" {}
# variable "private_subnet_cidrs" {}
# variable "domain_name" {}
# variable "subdomain" {}
# variable "create_route53_zone" {}

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
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
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
  source                = "./modules/ec2"
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  target_group_arn      = module.elb.target_group_arn
  web_security_group_id = module.security.web_security_group_id
}





