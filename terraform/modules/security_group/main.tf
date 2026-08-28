terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  base_ingress = [
    {
      description = "SSH from admin IP only"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowed_cidr]
    },
    {
      description = "Flask API from anywhere"
      from_port   = var.app_port
      to_port     = var.app_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  http_ingress = var.enable_http ? [{
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }] : []

  https_ingress = var.enable_https ? [{
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }] : []

  ingress_rules = concat(
    local.base_ingress,
    local.http_ingress,
    local.https_ingress,
  )
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-"
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      security_groups  = egress.value.security_groups
      self             = egress.value.self
    }
  }

  # Pairs with name_prefix: AWS refuses to delete a security group that is
  # still attached to an instance, so the replacement must exist first.
  lifecycle {
    create_before_destroy = true
  }
}
