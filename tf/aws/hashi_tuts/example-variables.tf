# Adding these without default values will trigger input requests at plan apply time.
# variable "access_key" {
#   type = "string"
#   description = "IAM programatic access key"
# }
# variable "secret_key" {
#   type = "string"
#   description = "IAM programatic secret key"
# }

# can override this on the cli with -var 'region=us-west-1'
variable "region" {
  type = "string"
  description = "aws target region"
  default = "us-west-2"
}

variable "vpc_cidr" {
  type = "string"
  description = "the cidr block for the vpc"
  default = "10.1.0.0/16"
}

# Wonder for this if map would be better.
variable "vpc_public_subnets" {
  type = "list"
  description = "the public subnets in the vpc"
  default = ["10.1.1.0/24","10.1.2.0/24"]
}

# us-west-2
# ami-0cb72367e98845d43 (64-bit x86) # amazon linux 
# ami-005bdb005fb00e791 (63-bit x86) # ubuntu 18.04

variable "amazon_linux_amis" {
  type = "map"
  description = "the amazon linux ami ids by region"
  default = {
    us-west-2 = "ami-0cb72367e98845d43"
    us-west-1 = "need_to_add_will_fail"
  }
}

# add another layer of variable abstraction reference file terraform.tfvars (HAS to be this name)
variable "ubuntu_amis" {
  type = "map"
  description = "ubuntu amis from the public ami market"
  # stored in terraform.tfvars
}