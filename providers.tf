terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17"
    }
  }

  required_version = "~> 1.2"
}

provider "aws" {
  default_tags {
    tags = {
      Owner = "Terraform"
      Name  = var.project
    }
  }

  region = var.region
}