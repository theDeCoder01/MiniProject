output "id" {
  description = "The EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "The private IP address of the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "The public IP address of the instance."
  value       = aws_instance.this.public_ip
}
