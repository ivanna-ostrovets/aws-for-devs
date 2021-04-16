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
  hash_key     = var.dynamodb_table_hash_key
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = var.dynamodb_table_hash_key
    type = "S"
  }
}

resource "aws_db_instance" "postgres" {
  engine                 = "postgres"
  identifier             = "week6-postgres"
  multi_az               = true
  allocated_storage      = var.rds_allocated_storage
  engine_version         = var.postgres_engine_version
  instance_class         = var.rds_instance_type
  password               = var.rds_username
  username               = var.rds_password
  port                   = var.rds_port
  vpc_security_group_ids = [module.security_groups.rds_security_group_id]
  db_subnet_group_name   = module.vpc.private_subnet_group_name
  skip_final_snapshot    = true
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "sqs_queue_name"
}

resource "aws_sns_topic" "sns_topic" {
  name = "sns_topic_name"
}

module "iam" {
  source = "./iam"
}

module "vpc" {
  source                = "./vpc"
  nat_instance_id       = module.ec2.nat_instance_id
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "security_groups" {
  source                = "./security_groups"
  vpc_id                = module.vpc.vpc_id
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "ec2" {
  source                    = "./ec2"
  public_subnet_1_id        = module.vpc.public_subnet_1_id
  public_subnet_2_id        = module.vpc.public_subnet_2_id
  private_subnet_1_id       = module.vpc.private_subnet_1_id
  private_subnet_2_id       = module.vpc.private_subnet_2_id
  vpc_id                    = module.vpc.vpc_id
  iam_instance_profile_name = module.iam.iam_instance_profile_name
  public_security_group_id  = module.security_groups.public_security_group_id
  private_security_group_id = module.security_groups.private_security_group_id
  rds_address               = aws_db_instance.postgres.address
  rds_connect_string        = "postgresql://${var.rds_username}:${var.rds_password}@${aws_db_instance.postgres.endpoint}/postgres"
}