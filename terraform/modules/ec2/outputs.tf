output "id" {
  description = "The EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "The private IP address of the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "The public IP address of the instance — the Elastic IP if one was created, otherwise the instance's own public IP."
  value       = var.create_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "key_name" {
  description = "The key pair name used for the instance."
  value       = aws_instance.this.key_name
}
