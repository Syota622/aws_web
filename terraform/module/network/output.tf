# # Output: VPCs
# output "vpc_id" {
#   description = "The ID of the Dev VPC"
#   value       = aws_vpc.main.id
# }

# output "public_subnet_ids" {
#   value = { for k, subnet in aws_subnet.public : k => subnet.id }
# }

# output "private_subnet_ids" {
#   value = { for k, subnet in aws_subnet.private : k => subnet.id }
# }
