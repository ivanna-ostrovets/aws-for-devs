output "load_balancer_dns_name" {
  value       = module.ec2.load_balancer_dns_name
  description = "DNS name of load balancer"
}

output "private_ec2_ip" {
  value       = module.ec2.private_ec2_ip
  description = "Private EC2 instance IP"
}

output "rds_address" {
  value       = aws_db_instance.postgres.address
  description = "The hostname of the RDS instance"
}

output "public_ec2_ips" {
  value       = module.ec2.public_ec2_ips
  description = "Initial IPs of public EC2 instances"
}
