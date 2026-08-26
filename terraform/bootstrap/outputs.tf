output "state_bucket_name" {
  description = "S3 bucket holding Terraform state. Goes in ../backend.tf."
  value       = aws_s3_bucket.state.id
}

output "lock_table_name" {
  description = "DynamoDB table used for state locking. Goes in ../backend.tf."
  value       = aws_dynamodb_table.locks.name
}

output "state_bucket_arn" {
  description = "Bucket ARN -- use it to scope the IAM policy for the Terraform user."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_arn" {
  description = "Lock table ARN -- use it to scope the IAM policy for the Terraform user."
  value       = aws_dynamodb_table.locks.arn
}

# Run `terraform output backend_config_snippet` and paste the result straight
# into ../backend.tf.

output "backend_config_snippet" {
  description = "Ready-to-paste backend block for the root configuration."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.state.id}"
        key            = "miniproject1/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.locks.name}"
        encrypt        = true
      }
    }
  EOT
}


# lock_table_arn = "arn:aws:dynamodb:eu-central-1:146558977169:table/miniproject1-tf-locks"
# lock_table_name = "miniproject1-tf-locks"
# state_bucket_arn = "arn:aws:s3:::miniproject1-tfstate-146558977169"
# state_bucket_name = "miniproject1-tfstate-146558977169"
