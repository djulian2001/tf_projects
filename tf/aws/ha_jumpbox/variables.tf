# variables.tf

variable "region" {
  type = "string"
  description = "The aws target region"
  default = "us-west-2"
}

variable "vpc_cidr" {
  type = "string"
  description = "The vpc cidr block to use."
  default = "10.0.0.0/16"
}

variable "vpc_cidr_testbox" {
  type = "string"
  description = "The vpc cidr block for the test box we will access from the jumpbox"
  default = "10.55.1.0/24"
}

# setting as env variable
variable "my_public_ip" {
  type = "string"
  description = "the public ip address of my router"
# interesting 
# dig +short myip.opendns.com @resolver1.opendns.com
# dig TXT +short o-o.myaddr.1.google.com @ns1.google.com
}

variable "subnet_public_jumpbox" {
  type = "map"
  description = "the public jumpbox and elp subnets"
  default = {
    us-west-2a = "10.0.1.0/24"
    us-west-2b = "10.0.2.0/24"
  }
}
