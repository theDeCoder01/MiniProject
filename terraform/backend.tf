terraform {
  backend "s3" {
    bucket         = "miniproject1-tfstate-146558977169"
    key            = "terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "miniproject1-tf-locks"
    encrypt        = true

  }
}

