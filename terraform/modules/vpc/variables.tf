variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "aws_availability_zones" {
  type        = list(string)
  description = "List of availability zones for the VPC"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
