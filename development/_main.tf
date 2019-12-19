provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "/home/user/.aws/credentials"
  profile                 = "${var.profile}"
}

# resource "aws_s3_bucket" "terraform" {
#   bucket = "terraform"
#   acl    = "private"
#   key    = "terraform/"
# }
#
# resource "aws_s3_bucket" "dev" {
#   bucket     = "dev"
#   acl        = "private"
#   key        = "terraform/dev"
# }

# terraform {
#   backend "s3" {
#     bucket = "foo-tf-state"
#     key    = "terraform/dev/terraform.tfstate"
#     region = "us-east-2"
#   }
# }

# data "terraform_remote_state" "static" {
#   backend = "s3"
#   config = {
#     bucket = "foo-tf-state"
#     key    = "terraform/dev/terraform.tfstate"
#     region = "us-east-2"
#   }
# }

resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment}"
  tags = {
    Name        = "${var.environment}"
    Environment = "${var.environment}"
  }
}
