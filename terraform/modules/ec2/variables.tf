variable "name" {
  description = "Name tag for the EC2 instance."
  type        = string
}

variable "public_key_path" {
  description = "Path to the public half of the dedicated project SSH key"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet in which to launch the instance."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to the instance."
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 8
}

variable "repo_url" {
  description = "URL of the Git repository to clone."
  type        = string
  default     = "https://github.com/theDeCoder01/MiniProject.git"
}

variable "app_port" {
  description = "Port on which the Flask application will run."
  type        = number
  default     = 5000
}

variable "create_eip" {
  description = "Whether to create an Elastic IP for the instance."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment tag applied to every resource (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name, used as a prefix for resource names and tags across every module."
  type        = string
  default     = "project1"
}

#No need for ami_id since the module fetches it dynamically.
#However, it was added to be able to toggle envs.
variable "ami_id" {
  description = "Pin a specific AMI ID for a stable, reproducible environment. Leave null (default) to always resolve the latest available Ubuntu 22.04 AMI at plan time."
  type        = string
  default     = null
}
