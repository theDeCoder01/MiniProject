output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = values(aws_subnet.public)[*].id
  description = "The IDs of the public subnets, ordered by subnet key"
}

output "public_subnet_ids_by_name" {
  value       = { for key, subnet in aws_subnet.public : key => subnet.id }
  description = "Public subnet IDs keyed by the name given in var.public_subnets"
}

output "vpc_cidr_block" {
  value       = aws_vpc.this.cidr_block
  description = "The CIDR block of the VPC"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id
  description = "The ID of the internet gateway"
}
