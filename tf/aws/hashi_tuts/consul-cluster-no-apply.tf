# this will cost me money just plan no apply
# errors anyways:
# "Error: Unsupported Terraform Core version"  # running 0.12.0
terraform {
  required_version = "0.11.11"
}
provider "aws" {
  region = "us-east-1"
}
module "consul" {
  source = "hashicorp/consul/aws"
  aws_region = "us-east-1"
  num_servers = "3"
}
