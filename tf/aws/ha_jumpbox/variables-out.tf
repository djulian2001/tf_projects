# print out some out put variables
output "ec2-testbox-private-ip" {
  value = aws_instance.ec2-testbox.private_ip
}

output "ec2-jumpbox-public-ip" {
  value = aws_instance.ec2-jumpbox.public_ip
}
