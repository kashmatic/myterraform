terraform {
  required_version = ">=0.12.0"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1a"
}

resource "aws_s3_bucket" "mybucket" {

}

## Objects not managed by Terraform
data "aws_caller_identity" "current" {

}
