output "iam_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_iam_instance_profile.name
  description = "Name of IAM instance profile"
}