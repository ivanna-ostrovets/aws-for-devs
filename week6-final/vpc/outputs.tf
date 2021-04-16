output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "VPC id"
}

output "public_subnet_1_id" {
  value       = aws_subnet.public_subnet_1.id
  description = "Id of first public subnet"
}

output "public_subnet_2_id" {
  value       = aws_subnet.public_subnet_2.id
  description = "Id of second public subnet"
}

output "private_subnet_1_id" {
  value       = aws_subnet.private_subnet_1.id
  description = "Id of first private subnet"
}

output "private_subnet_2_id" {
  value       = aws_subnet.private_subnet_2.id
  description = "Id of second private subnet"
}

output "private_subnet_group_name" {
  value       = aws_db_subnet_group.private_subnet_group.name
  description = "Name of private subnet group"
}