terraform {
  required_version = ">=0.12.0"
}

provider "aws" {
  region = "us-east-2"
}


## define the s3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "kashi-terraform-state"

  ## prevent accidental deletion of this bucket
  # lifecycle {
  #   prevent_destroy = true
  # }
  force_destroy = true

  ## enable versioning
  versioning {
    enabled = true
  }

  ## enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

## define DynamoDB
resource "aws_dynamodb_table" "terraform_table" {
  name         = "kashi-terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
