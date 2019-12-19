variable "environment" {
  description = "The environment"
  default     = "foo-dev"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "availability_zones" {
  type        = list
  description = "AZs to cover in a given region"
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "security_group_name" {
  description = "Name of the security group for Main VPC"
}
