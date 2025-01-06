output "subnet_1a_id" {
  value       = aws_subnet.maged-public-subnet-1a.id
  description = "The ID of the public subnet in availability zone 1a"
}

output "subnet_1b_id" {
  value       = aws_subnet.maged-public-subnet-1b.id
  description = "The ID of the public subnet in availability zone 1b"
}

output "private_subnet_1a_id" {
  value       = aws_subnet.maged-private-subnet-1a.id
  description = "The ID of the public subnet in availability zone 1b"
}
output "vpc_id" {
  value       = aws_vpc.maged-terraform-vpc.id
  description = "The ID of the public subnet in availability zone 1b"
}


