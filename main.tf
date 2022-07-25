variable "prefix" {
  default = "s3www-"
}
variable "aws_region" {
  default = "ap-northeast-3"
}
variable "author_mail" {
  default = "foo@example.com"
}
locals {
  prefix = var.prefix # just as macro
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      mail         = var.author_mail
      project_name = "s3www"
      provided_by  = "Terraform"
    }
  }
}
