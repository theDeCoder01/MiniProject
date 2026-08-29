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
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-central-1a"
    }
  }
}

module "security_group" {
  source = "./modules/security_group"

  name             = "${var.project_name}-sg"
  vpc_id           = module.vpc.vpc_id
  ssh_allowed_cidr = var.ssh_allowed_cidr
  app_port         = var.app_port
  # enable_http / enable_https omitted: falls through to the module's own
  # defaults (both false) -- flip them directly here if you attempt the
  # HTTPS bonus.
}

module "ec2" {
  source = "./modules/ec2"

  name              = "${var.project_name}-app"
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
  public_key_path   = var.public_key_path
  app_port          = var.app_port
  # instance_type / root_volume_size / repo_url / create_eip omitted: each
  # falls through to the module's own default.
}
