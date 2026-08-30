terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# This is to satisfy the requirement that the security group module
#should only allow "My IP" for SSH access. It auto-detects the IP
#at plan/apply time.
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  # var.ssh_allowed_cidr can't just be passed straight through when null:
  # explicitly passing null into a module argument stays null, it does NOT
  # fall back to that module's own default (only OMITTING the argument
  # does). So the coalesce has to happen here, before the module call.
  ssh_allowed_cidr = coalesce(var.ssh_allowed_cidr, "${chomp(data.http.my_ip.response_body)}/32")
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
  ssh_allowed_cidr = local.ssh_allowed_cidr
  app_port         = var.app_port
}

module "ec2" {
  source = "./modules/ec2"

  name              = "${var.project_name}-app"
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
  public_key_path   = var.public_key_path
  app_port          = var.app_port
  # The following variables are passed through to be able ro toggle envs.
  environment      = var.environment
  project_name     = var.project_name
  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size
  ami_id           = var.ami_id
}
