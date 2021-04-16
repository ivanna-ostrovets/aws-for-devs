terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region = "us-west-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
  validation {
    condition = contains(["t2.micro", "t2.small"], var.instance_type)
    error_message = "Argument \"instance_type\" must be either \"t2.micro\" or \"t2.small\"."
  }
}

variable "image_id" {
  description = "The ID of the AMI"
  type = string
  default = "ami-44da5574"
}

variable "key_name" {
  description = "Key pair credentials for SSH connection into an EC2 instance"
  type = string
  default = "aws"
}

variable "s3_bucket_name" {
  description = "Name of S3 Bucket"
  type = string
  default = "s3_bucket_name"
}

resource "aws_launch_template" "ec2_launch_template" {
  name_prefix = "ec2_launch_template"
  image_id = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  security_group_names = [
    aws_security_group.ssh_security_group.name,
    aws_security_group.http_security_group.name,
  ]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_iam_instance_profile.name
  }
  user_data = base64encode(
  <<EOT
      ${file("${path.module}/scripts/init-ec2.sh")}

      /usr/local/bin/aws s3 cp s3://${var.s3_bucket_name}/test-file.txt test-file.txt
  EOT
  )
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  availability_zones = data.aws_availability_zones.available.names
  desired_capacity = 2
  max_size = 2
  min_size = 2

  launch_template {
    id = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
}

resource "aws_security_group" "ssh_security_group" {
  description = "Allow SSH access to EC2 instance"
  name_prefix = "ssh_security_group"

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http_security_group" {
  description = "Allow HTTP access to EC2 instance"
  name_prefix = "http_security_group"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  role = aws_iam_role.s3_role.name
}

resource "aws_iam_role" "s3_role" {
  name = "s3_role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "s3_policy"
    policy = jsonencode({
      Statement = [
        {
          Action = ["s3:*"]
          Effect = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

output "ssh_security_group_id" {
  value = aws_security_group.ssh_security_group.id
  description = "Id of created ssh_security_group"
}

output "http_security_group_id" {
  value = aws_security_group.http_security_group.id
  description = "Id of created http_security_group"
}

output "auto_scaling_group_name" {
  value = aws_autoscaling_group.auto_scaling_group.name
  description = "Name of created Auto Scaling group"
}

output "ec2_launch_template_latest_version" {
  value = aws_launch_template.ec2_launch_template.latest_version
  description = "The latest version of the EC2 launch template"
}
