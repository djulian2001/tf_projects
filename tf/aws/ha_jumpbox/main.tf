#########################################################################################
# create an HA jumpbox resource(s) with an elb and asg 
#
#


#########################################################################################
# network objects 
#########################################################################################

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc-jumpbox" {
  cidr_block = var.vpc_cidr
}

resource "aws_vpc" "vpc-testbox" {
  cidr_block = var.vpc_cidr_testbox
}

resource "aws_subnet" "subnet-jumpbox-a" {
  vpc_id = aws_vpc.vpc-jumpbox.id
  cidr_block = var.subnet_public_jumpbox["us-west-2a"]
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "subnet-jumpbox-b" {
  vpc_id = aws_vpc.vpc-jumpbox.id
  cidr_block = var.subnet_public_jumpbox["us-west-2b"]
  map_public_ip_on_launch = true
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "subnet-testbox-a" {
  vpc_id = aws_vpc.vpc-testbox.id
  cidr_block = var.vpc_cidr_testbox
  availability_zone = "us-west-2a"
}

#########################################################################################
# network routing
#########################################################################################

resource "aws_internet_gateway" "igw-jumpbox" {
  vpc_id = aws_vpc.vpc-jumpbox.id
  tags = {
    Name = "main"
  }
}

resource "aws_vpc_peering_connection" "jumpbox-to-testbox" {
  peer_vpc_id = aws_vpc.vpc-jumpbox.id
  vpc_id = aws_vpc.vpc-testbox.id
  auto_accept = true

  tags = {
    Name = "peer-jump-to-test"
  }
}

resource "aws_route_table" "rt-main-jumpbox" {
  vpc_id = aws_vpc.vpc-jumpbox.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-jumpbox.id
  }

  route {
    cidr_block = var.vpc_cidr_testbox
    vpc_peering_connection_id = aws_vpc_peering_connection.jumpbox-to-testbox.id
  }

  tags = {
    Name = "main-jump"
  }
}

resource "aws_route_table_association" "rt-subnet-jumpbox-a" {
  subnet_id = aws_subnet.subnet-jumpbox-a.id
  route_table_id = aws_route_table.rt-main-jumpbox.id
}

resource "aws_route_table_association" "rt-subnet-jumpbox-b" {
  subnet_id = aws_subnet.subnet-jumpbox-b.id
  route_table_id = aws_route_table.rt-main-jumpbox.id
}

resource "aws_route_table" "rt-main-testbox" {
  vpc_id = aws_vpc.vpc-testbox.id

  route {
    cidr_block = var.vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.jumpbox-to-testbox.id
  }

  tags = {
    Name = "main-test"
  } 
}

resource "aws_route_table_association" "rt-subnet-testbox-a" {
  subnet_id = aws_subnet.subnet-testbox-a.id
  route_table_id = aws_route_table.rt-main-testbox.id
}

#########################################################################################
# network security
# Going to add rules as inline vs resource and type (one OR the other but NOT both...)
#########################################################################################

resource "aws_network_acl" "nacl-jumpbox" {
  vpc_id = aws_vpc.vpc-jumpbox.id
  
  subnet_ids = [
    aws_subnet.subnet-jumpbox-a.id,
    aws_subnet.subnet-jumpbox-b.id
  ]

  ingress {
    rule_no = 100
    protocol = "tcp"
    action = "allow"
    cidr_block = "${join("/",[var.my_public_ip,"32"])}"
    from_port = 22
    to_port = 22
  }

  # icmp echo reply 0
  ingress {
    rule_no = 300
    protocol = "icmp"
    icmp_type = 0
    icmp_code = 0
    action = "allow"
    cidr_block = var.vpc_cidr_testbox
    from_port = 0
    to_port = 0
  }

  # ssh response
  egress {
    rule_no = 100
    protocol = "tcp"
    action = "allow"
    cidr_block = "${join("/",[var.my_public_ip,"32"])}"
    from_port = 1024
    to_port = 65535
  }

  # icmp echo 8
  egress {
    rule_no = 300
    protocol = "icmp"
    icmp_type = 8
    icmp_code = 8
    action = "allow"
    cidr_block = var.vpc_cidr_testbox
    from_port = 0
    to_port = 0
  }

}

resource "aws_network_acl" "nacl-testbox" {
  vpc_id = aws_vpc.vpc-testbox.id

  subnet_ids = [
    aws_subnet.subnet-testbox-a.id
  ]

  ingress {
    rule_no = 300
    protocol = "icmp"
    icmp_type = 8
    icmp_code = 8
    action = "allow"
    cidr_block = var.vpc_cidr
    from_port = 0
    to_port = 0 
  }

  egress {
    rule_no = 300
    protocol = "icmp"
    icmp_type = 0
    icmp_code = 0
    action = "allow"
    cidr_block = var.vpc_cidr
    from_port = 0
    to_port = 0
  }

}

resource "aws_security_group" "sg-elb" {
  name        = "sg_elb"
  description = "security group for the classic load balancer ENI"
  vpc_id      = aws_vpc.vpc-jumpbox.id
}

resource "aws_security_group" "sg-jumpbox" {
  name        = "sg_jumpbox"
  description = "the security group for the jumpbox"
  vpc_id      = aws_vpc.vpc-jumpbox.id
}

resource "aws_security_group" "sg-testbox" {
  name        = "sg_testbox"
  description = "the security group for the testbox"
  vpc_id      = aws_vpc.vpc-testbox.id
}

# sg rules
resource "aws_security_group_rule" "sg-elb-ingress-ssh-rule" {
  security_group_id = aws_security_group.sg-elb.id
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${join("/",[var.my_public_ip,"32"])}"]
  description = "allow ssh connections from my home networks public ip"
}

resource "aws_security_group_rule" "sg-elb-egress-ssh-rule" {
  security_group_id = aws_security_group.sg-elb.id
  type        = "egress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = aws_security_group.sg-jumpbox.id
  description = "allow egress ssh connections to the jumpbox"  
}

resource "aws_security_group_rule" "sg-jumpbox-ingress-ssh-rule" {
  security_group_id = aws_security_group.sg-jumpbox.id
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = aws_security_group.sg-elb.id
  description = "allow ingress ssh connections"
}

resource "aws_security_group_rule" "sg-jumpbox-egress-icmp-rule" {
  security_group_id = aws_security_group.sg-jumpbox.id
  type        = "egress"
  from_port   = 8
  to_port     = 8
  protocol    = "icmp"
  source_security_group_id = aws_security_group.sg-testbox.id
  description = "allow egress echo to the testbox"
}

resource "aws_security_group_rule" "sg-testbox-ingress-icmp-rule" {
  security_group_id = aws_security_group.sg-testbox.id
  type        = "ingress"
  from_port   = 8
  to_port     = 8
  protocol    = "icmp"
  source_security_group_id = aws_security_group.sg-jumpbox.id
  description = "allow ingress echo from the jumpbox"
}

#########################################################################################
# compute resources
#########################################################################################

