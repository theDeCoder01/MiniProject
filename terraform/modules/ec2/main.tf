terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_key_pair" "this" {
  key_name_prefix = "${var.name}-"
  public_key      = file(var.public_key_path)
}

# Dynamic lookup for latest Ubuntu 22.04 LTS AMI
#This approach gaurantees that the module always
#uses the most recent (and correct) Ubuntu 22.04
#LTS AMI based on the selected region. It also
#prevents hardcoding certain AMI IDs that may get
#deprecated or removed in the future. 
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [var.security_group_id]
  user_data = templatefile("${path.module}/user_data.sh",
    {
      repo_url = var.repo_url
      app_port = var.app_port
  })

  user_data_replace_on_change = true
  root_block_device {
    volume_size = var.root_volume_size
  }


  tags = {
    Name = var.name
  }
}
