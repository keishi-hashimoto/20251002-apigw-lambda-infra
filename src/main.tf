terraform {
  required_version = ">=1.13"
  required_providers {
    aws = {
      version = ">=6.0"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {

  }
}

provider "aws" {
  default_tags {
    tags = {
      Category = "20251002-apigw-lambda"
      env      = terraform.workspace
    }
  }
}




