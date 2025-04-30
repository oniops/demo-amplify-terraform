terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.33.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "= 2.20.2"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

data "aws_ecr_authorization_token" "ecr" {}