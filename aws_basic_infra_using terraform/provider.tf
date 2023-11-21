#aws provider
#make sure to configure access key and secret key using aws configure
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}