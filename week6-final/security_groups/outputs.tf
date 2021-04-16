output "public_security_group_id" {
  value       = aws_security_group.public_security_group.id
  description = "Id of public security group"
}

output "private_security_group_id" {
  value       = aws_security_group.private_security_group.id
  description = "Id of private security group"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds_security_group.id
  description = "Id of RDS security group"
}
