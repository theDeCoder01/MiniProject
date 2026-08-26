###############################################################################
# Terraform state backend -- BOOTSTRAP
#
# Creates the S3 bucket and DynamoDB lock table that the ROOT configuration
# (../) uses as its remote backend.
#
# This config deliberately has NO backend block of its own: it uses local
# state. That is the point. A backend block is read before anything else runs,
# so a config cannot create the bucket it stores its own state in. Breaking
# that circle needs one small config that runs first, with local state.
#
# Run once, then never again:
#   terraform -chdir=terraform/bootstrap init
#   terraform -chdir=terraform/bootstrap plan
#   terraform -chdir=terraform/bootstrap apply
#   terraform -chdir=terraform/bootstrap output   # copy into ../backend.tf
#
# Its terraform.tfstate stays on this machine and is gitignored. If it is
# lost, the bucket and table still exist -- ../backend.tf refers to them by
# name, not by state -- so nothing breaks. You would just lose the ability to
# `plan` this config without `terraform import` first.
###############################################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Applied to every resource this config creates, so the tags never get
  # forgotten on an individual resource.
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "shared"
      Component   = "tf-state-backend"
      ManagedBy   = "terraform"
    }
  }
}

# makes S3 bucket name unique without hardcoding it in the source.
data "aws_caller_identity" "current" {}

locals {
  state_bucket_name = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
  lock_table_name   = "${var.project_name}-tf-locks"
}

###############################################################################
# S3 bucket -- holds the state files
#
# Note the shape of this section: on AWS provider v4+ the bucket's settings are
# NO LONGER nested blocks inside aws_s3_bucket. Each concern is its own
# resource pointing back at the bucket. Tutorials showing `versioning { }`
# inside the bucket resource predate that change and will not apply.
###############################################################################

resource "aws_s3_bucket" "state" {
  bucket = local.state_bucket_name

  # Destroying the bucket that holds every environment's state is
  # unrecoverable, so make Terraform refuse. Expected side effect:
  # `terraform destroy` in this directory fails until this block is removed.
  # That friction is the feature.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = local.state_bucket_name
  }
}

# Every previous revision of the state is retained. This is the undo button
# for a corrupted or half-written state file -- the worst failure mode in
# Terraform, and the main reason to use S3 rather than a local file.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# State files contain every attribute of every resource, sometimes including
# secrets in plaintext. SSE-S3 (AES256) is encryption at rest at no cost;
# SSE-KMS would add per-request charges for no real benefit at this scale.
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    # Cuts encryption request costs by reusing one data key per object batch.
    bucket_key_enabled = true
  }
}

# Belt and braces: a state bucket must never be reachable from the internet,
# regardless of any ACL or policy a future change might introduce.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning means every apply leaves another object version behind forever.
# Expire the old ones so the bucket does not grow without bound. 90 days is
# far longer than any rollback you would realistically perform.
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  # Expiring NON-CURRENT versions is meaningless until versioning is on, and
  # Terraform cannot infer that ordering on its own.
  depends_on = [aws_s3_bucket_versioning.state]

  rule {
    id     = "expire-noncurrent-state-versions"
    status = "Enabled"

    # An empty filter means "every object in the bucket". Modern provider
    # versions require either a filter or a prefix -- omitting both fails
    # validation with a message that does not point here.
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    # Clean up failed multipart uploads so they stop accruing storage.
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

###############################################################################
# DynamoDB table -- state locking
#
# Terraform writes an item here before an apply and deletes it afterwards, so
# a second `apply` blocks instead of racing and corrupting state.
###############################################################################

resource "aws_dynamodb_table" "locks" {
  name = local.lock_table_name

  # No idle cost: you are billed per request, and state locks are tiny and
  # rare. PROVISIONED would bill 24/7 for capacity you never use.
  billing_mode = "PAY_PER_REQUEST"

  # This name is NOT a choice. Terraform's S3 backend hardcodes an attribute
  # called exactly "LockID" of type "S". LockId or lock_id will not work.
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # DynamoDB already encrypts at rest by default with an AWS-owned key, at no
  # charge. An explicit server_side_encryption block switches to an AWS-managed
  # KMS key, which adds per-request KMS costs for no meaningful gain here --
  # so it is intentionally omitted.

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = local.lock_table_name
  }
}
