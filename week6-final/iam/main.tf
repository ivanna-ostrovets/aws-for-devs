terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  role = aws_iam_role.week6_ec2_role.name
}

resource "aws_iam_role" "week6_ec2_role" {
  name = "week6_final_ec2_role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      },
    ]
  })
}

resource "aws_iam_role_policy" "sqs_policy" {
  name = "sqs-policy"
  role = aws_iam_role.week6_ec2_role.id

  policy = jsonencode({
    Statement = [
      {
        Action   = [
          "sqs:DeleteMessage",
          "sqs:ListQueues",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "sns_policy" {
  name = "sns-policy"
  role = aws_iam_role.week6_ec2_role.id

  policy = jsonencode({
    Statement = [
      {
        Action   = [
          "SNS:CreateTopic",
          "SNS:Publish",
          "SNS:ListTopics"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "dynamodb_policy"
  role = aws_iam_role.week6_ec2_role.id

  policy = jsonencode({
    Statement = [
      {
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_policy"
  role = aws_iam_role.week6_ec2_role.id

  policy = jsonencode({
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
