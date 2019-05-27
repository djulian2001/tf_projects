# us-west-2
# ami-0cb72367e98845d43 (64-bit x86) # amazon linux 
# ami-005bdb005fb00e791 (63-bit x86) # ubuntu 18.04

# using the aws configure as setup
# adding env variables TF_VAR_access_key and TF_VAR_secret_key (another option)
provider "aws" {
  # access_key = var.access_key
  # secret_key = var.secret_key
  region  = var.region
}

# depends on example
resource "aws_s3_bucket" "my-s3-bucket" {
  bucket  = "djulian2001-my-s3-bucket"
  acl     = "private"
  
}

# ami value pulled from example-variables.tf file
resource "aws_instance" "my-tf-example" {
  ami           = "${lookup(var.amazon_linux_amis, var.region)}"
  instance_type = "t2.micro"
  depends_on = [aws_s3_bucket.my-s3-bucket]

}

resource "aws_eip" "my-eip" {
  instance = aws_instance.my-tf-example.id

}

resource "aws_instance" "solo-tf-example" {
  ami = "${lookup(var.ubuntu_amis, var.region)}"
  instance_type = "t2.micro"
  
  provisioner "local-exec" {
    command = "echo ${aws_instance.solo-tf-example.public_ip} > ip_address.txt"
  }
}
