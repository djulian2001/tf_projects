# the terraform variables we want values for...
# after apply
# query with cli_cmd: terraform output eip_ipv4
output "eip_ipv4" {
  value = aws_eip.my-eip.public_ip
}