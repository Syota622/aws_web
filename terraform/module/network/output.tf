# Output: VPCs
output "vpc_id" {
  value       = aws_vpc.main.id
}

output "public_a_subnet_ids" {
  value       = aws_subnet.public_a.id
}

output "public_c_subnet_ids" {
  value       = aws_subnet.public_c.id
}

output "public_d_subnet_ids" {
  value       = aws_subnet.public_d.id
}
