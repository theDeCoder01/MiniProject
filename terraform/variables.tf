variable "aws_region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "eu-central-1"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
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

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to reach SSH (port 22). Use your own public IP as a /32 -- never 0.0.0.0/0."
  type        = string
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
