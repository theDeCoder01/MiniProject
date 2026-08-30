variable "aws_region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "eu-central-1"
}

variable "cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "eu-central-1a"
}

variable "project_name" {
  description = "Project name, used as a prefix for resource names and tags across every module."
  type        = string
  default     = "project1"
}

variable "environment" {
  description = "Environment tag applied to resources (dev, staging, prod). Set explicitly in each env/*.tfvars file."
  type        = string
  default     = "dev"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to reach SSH (port 22). Leave null (default) to auto-detect your current public IP at plan/apply time -- see the http data source in main.tf. Set explicitly only to override that detection."
  type        = string
  default     = null
}

variable "public_key_path" {
  description = "Path to the public half of the dedicated project SSH key (see terraform/keys/), relative to this directory."
  type        = string
}

variable "app_port" {
  description = "Port the Flask app listens on. Shared by the security group and the EC2 module so the two can never drift apart."
  type        = number
  default     = 5000
}

#Variables introduced in order to be able to toggle envs.
variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume, in GB."
  type        = number
  default     = 8
}

variable "ami_id" {
  description = "Pin a specific AMI ID for a stable, reproducible environment. Leave null (default) to always resolve the latest available Ubuntu 22.04 AMI at plan time."
  type        = string
  default     = null
}
