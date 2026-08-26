variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
  default     = "project1"
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnets" {
  description = "Public subnets to create, keyed by a stable name used in the resource address and tags."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  validation {
    condition     = length(var.public_subnets) > 0
    error_message = "At least one public subnet must be defined."
  }
}
