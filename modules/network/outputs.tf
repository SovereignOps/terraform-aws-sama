output "vpc_id" {
  value = aws_vpc.sama_vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "nacl_id" {
  value = aws_network_acl.sama_nacl.id
}
