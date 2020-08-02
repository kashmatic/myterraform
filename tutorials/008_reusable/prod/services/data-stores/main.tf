terraform {
  required_version = ">=0.12.0"

  backend "s3" {
    key            = "stage/services/data-stores/terraform.tfstate"
    bucket         = "kashi-terraform-state"
    region         = "us-east-2"
    dynamodb_table = "kashi-terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database"
  username          = "admin"

  # How should we set the password?
  password = var.db_password

  ## settings
  skip_final_snapshot = true
}
