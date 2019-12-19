module "networking" {
  source               = "../modules/networking"
  environment          = "foo-dev"
  aws_region           = "us-east-2"
  security_group_name  = "foo-dev-security-group"
  vpc_cidr             = "10.0.0.0/16"
  private_subnets_cidr = ["10.0.1.0/24"]
  public_subnets_cidr  = ["10.0.129.0/24"]
  availability_zones   = ["us-east-2a"]
}
