output "public_ec2_ip" {
  value = aws_instance.ec2_instance_public.public_ip
  description = "Public IP of EC2 instance"
}

output "private_ec2_ip" {
  value = aws_instance.ec2_instance_private.private_ip
  description = "Private IP of EC2 instance"
}

output "load_balancer_dns_name" {
  value = aws_lb.load_balancer.dns_name
  description = "DNS name of load balancer"
}
