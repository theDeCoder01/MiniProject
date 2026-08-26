variable "aws_region" {
  description = "Region that will hold the state bucket and lock table."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Prefix for the backend resource names."
  type        = string
  default     = "miniproject1"
}
