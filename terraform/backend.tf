terraform {
  backend "s3" {
    # Fill in these values before running terraform init.
    bucket         = "<S3_BUCKET_NAME>"
    key            = "terraform.tfstate"
    region         = "<AWS_REGION>"
    dynamodb_table = "<DYNAMODB_TABLE_NAME>"
    encrypt        = true

    # Reference values for the resources above (not accepted by the backend block):
    # bucket_arn = "<S3_BUCKET_ARN>"
    # table_arn  = "<DYNAMODB_TABLE_ARN>"
  }
}

