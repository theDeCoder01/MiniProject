terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  name = var.project_name
  public_subnets = {
    a = {
      cidr_block        = var.cidr_block
      availability_zone = var.availability_zone
      #This is hard-coded because the backend was created there.
    }
  }
}

module "security_group" {
  source = "./modules/security_group"

  name             = "${var.project_name}-sg"
  vpc_id           = module.vpc.vpc_id
  ssh_allowed_cidr = var.ssh_allowed_cidr
  app_port         = var.app_port
}

module "ec2" {
  source = "./modules/ec2"

  name              = "${var.project_name}-app"
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
  public_key_path   = var.public_key_path
  app_port          = var.app_port
}
