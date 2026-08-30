output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_ids[0]
  # the [0] because module.vpc.public_subnet_ids is a list, not a string --
  # this output holds just the one subnet this project deploys into.
  description = "The ID of the public subnet"
}

output "security_group_id" {
  value       = module.security_group.security_group_id
  description = "The ID of the security group"
}

output "ec2_instance_id" {
  value       = module.ec2.id
  description = "The ID of the EC2 instance"
}

output "ec2_instance_public_ip" {
  value       = module.ec2.public_ip
  description = "The public IP address of the EC2 instance"
}

output "ec2_instance_private_ip" {
  value       = module.ec2.private_ip
  description = "The private IP address of the EC2 instance"
}

output "ec2_instance_key_name" {
  value       = module.ec2.key_name
  description = "The key pair name used for the EC2 instance"
}
