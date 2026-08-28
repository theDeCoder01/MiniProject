variable "name" {
  description = "Name of the security group."
  type        = string
}

variable "description" {
  description = "Description of the security group."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the security group."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to reach SSH. Your public IP as a /32."
  type        = string
}

variable "app_port" {
  description = "Port the Flask application listens on."
  type        = number
  default     = 5000
}

variable "enable_http" {
  description = "Toggle to allow HTTP (port 80) from anywhere."
  type        = bool
  default     = false
}

variable "enable_https" {
  description = "Toggle to allow HTTPS (port 443) from anywhere."
  type        = bool
  default     = false
}

variable "egress_rules" {
  description = "Egress rules for the security group."
  type = list(object({
    description      = optional(string)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    security_groups  = optional(list(string), [])
    self             = optional(bool, false)
  }))
  default = [{
    description     = "Allow all outbound traffic"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
    self            = false
  }]
}
