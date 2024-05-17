provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      env     = "prod",
      project = "learn"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
  }

  required_version = "= 1.8.3"

  backend "s3" {
    bucket         = "learn-terraform-tfstate-prod" # create terraform s3 bucket
    region         = "ap-northeast-1"
    key            = "terraform.tfstate"
    encrypt        = true
    dynamodb_table = "learn-terraform-lock-prod" # dynamodb lock
  }
}
