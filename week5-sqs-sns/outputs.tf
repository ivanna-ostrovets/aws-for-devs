output "ec2_public_ip" {
  value = aws_instance.ec2_instance.public_ip
  description = "EC2 instance public IP"
}

output "sqs_url" {
  value = aws_sqs_queue.sqs_queue.id
  description = "SQS URL"
}

output "sns_topic_arn" {
  value = aws_sns_topic.sns_topic.arn
  description = "SNS arn"
}