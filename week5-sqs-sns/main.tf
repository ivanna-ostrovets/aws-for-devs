terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "sqs-queue"
}

resource "aws_sns_topic" "sns_topic" {
  name = "sns-topic"
}

resource "aws_instance" "ec2_instance" {
  ami                  = var.image_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_iam_instance_profile.name
  security_groups      = [aws_security_group.ssh_security_group.name]
  user_data            = filebase64("${path.module}/../scripts/init-ec2.sh")
}

resource "aws_security_group" "ssh_security_group" {
  description = "Allow SSH access to EC2 instance"
  name_prefix = "ssh_security_group"

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  role = aws_iam_role.week5_ec2_role.name
}

resource "aws_iam_role" "week5_ec2_role" {
  name = "week5_ec2_role"

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
  role = aws_iam_role.week5_ec2_role.id

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "sns_policy" {
  name = "sns-policy"
  role = aws_iam_role.week5_ec2_role.id

  policy = jsonencode({
    Statement = [
      {
        Action = ["SNS:Publish"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
