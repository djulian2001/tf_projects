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
  default = "10.1.0.0/16"
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

variable "subnet_private_testbox" {
  type = "map"
  description = "the private testbox subnets"
  default = {
    us-west-2a = "10.1.1.0/24"
    us-west-2b = "10.1.2.0/24"
  }
}


variable "amazon_linux_amis" {
  type = "map"
  description = "the amazon linux ami ids by region"
  default = {
    us-west-2 = "ami-0cb72367e98845d43"
    us-west-1 = "ami-015954d5e5548d13b"
  }
}
## CLI cmds to get the image in other regions that matches us-west-2 amazon linux 2 image
# aws ec2 describe-images --image-ids ami-0cb72367e98845d43 --query "Images[].ImageLocation"
# [
#     "amazon/amzn2-ami-hvm-2.0.20190508-x86_64-gp2"
# ]
# aws ec2 describe-images \
#   --owners amazon \
#   --filter Name=architecture,Values=x86_64 \
#   --filter Name=hypervisor,Values=xen \
#   --filter Name=virtualization-type,Values=hvm \
#   --filter Name=image-type,Values=machine \
#   --filter Name=manifest-location,Values=amazon/amzn2-ami-hvm-2.0.20190508-x86_64-gp2 \
#   --region us-west-1
## THIS worked, same result
# aws ec2 describe-images \
#   --owners amazon \
#   --filter Name=manifest-location,Values=amazon/amzn2-ami-hvm-2.0.20190508-x86_64-gp2 \
#   --region us-west-1 --query "Images[].ImageId"
# [
#     "ami-015954d5e5548d13b"
# ]

variable "dev_rsa_key" {
  type = "string"
  description = "development ssh-rsa public key"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGVjErEgS8eSzLhrvYIrsv73kCBC51sKBCuID01BLMntHZ5vOf+I/QyitdD9/VPqw2dCH9EC72MhpARLTioS9/Z0J6IPFErsRTiiQpreZnMXWo2Z1l7GzHFsf3VeE3rH9obht5XNRadq1XVq/tD/bal3ZG/BYOrp7d/PLVw5DZsJiab9Wp1yItqzOrHS2PP3I+hG8jbV+PA9uDRLnr0VFpjQ5YCdhePaCDFBnJehXJZ/k1rXuRTlOPYc3cWoJEdTzfb04XuwrVV9BQhjIVpY+9INblFY86nHLNdhkXLj8/cPKldPBMas/m1Ppfw82c8Lt4cAksjnCfkmhra0++0GMh vagrant@localhost.localdomain"
}