output "private_ec2_ip" {
  value       = aws_instance.ec2_instance_private.private_ip
  description = "Private EC2 instance IP"
}

output "load_balancer_dns_name" {
  value       = aws_lb.load_balancer.dns_name
  description = "DNS name of load balancer"
}

output "nat_instance_id" {
  value       = aws_instance.nat_instance.id
  description = "Id of NAT EC2 instance"
}

output "public_ec2_ips" {
  value       = data.aws_instances.public_ec2_instances.public_ips
  description = "Initial IPs of public EC2 instances"
}

