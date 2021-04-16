output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
  description = "RDS endpoint"
}

output "rds_port" {
  value = aws_db_instance.postgres.port
  description = "RDS port"
}

output "dynamo_db_table_name" {
  value = aws_dynamodb_table.dynamodb_table.id
  description = "DynamoDB table name"
}