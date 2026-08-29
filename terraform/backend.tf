terraform {
  backend "s3" {
    bucket         = "miniproject1-tfstate-146558977169"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "miniproject1-tf-locks"
    encrypt        = true

  }
}

