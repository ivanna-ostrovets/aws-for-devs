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

resource "aws_dynamodb_table" "dynamodb_table" {
  name         = var.dynamodb_table_name
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "N"
  }
}

resource "aws_db_instance" "postgres" {
  engine                 = "postgres"
  identifier             = "week-3-postgres"
  multi_az               = true
  allocated_storage      = var.rds_allocated_storage
  engine_version         = var.postgres_engine_version
  instance_class         = var.rds_instance_type
  password               = var.rds_password
  username               = var.rds_username
  port                   = var.rds_port
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  skip_final_snapshot    = true
}

resource "aws_instance" "ec2_instance" {
  ami                  = var.image_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_iam_instance_profile.name

  security_groups = [
    aws_security_group.ssh_security_group.name,
    aws_security_group.http_security_group.name,
  ]

  user_data = base64encode(
  <<EOT
      ${file("${path.module}/../scripts/init-ec2.sh")}

      /usr/local/bin/aws s3 cp s3://${var.s3_bucket_name}/dynamodb-script.sh dynamodb-script.sh
      /usr/local/bin/aws s3 cp s3://${var.s3_bucket_name}/rds-script.sql rds-script.sql
  EOT
  )
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

resource "aws_security_group" "http_security_group" {
  description = "Allow HTTP access to EC2 instance"
  name_prefix = "http_security_group"

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_security_group" {
  description = "Allow access to DB instance"
  name_prefix = "db_security_group"

  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  role = aws_iam_role.week3_ec2_role.name
}

resource "aws_iam_role" "week3_ec2_role" {
  name = "week3_ec2_role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      },
    ]
  })

  inline_policy {
    name   = "s3_policy"
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

  inline_policy {
    name   = "dynamodb_policy"
    policy = jsonencode({
      Statement = [
        {
          Action   = [
            "dynamodb:ListTables",
            "dynamodb:PutItem",
            "dynamodb:GetItem",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}
