variable "name" {
  description = "Name tag for the EC2 instance."
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
