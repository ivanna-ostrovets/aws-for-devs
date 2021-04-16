variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small"], var.instance_type)
    error_message = "Argument \"instance_type\" must be either \"t2.micro\" or \"t2.small\"."
  }
}

variable "image_id" {
  description = "The ID of the AMI"
  type        = string
  default     = "ami-44da5574"
}

variable "key_name" {
  description = "Key pair credentials for SSH connection into an EC2 instance"
  type        = string
  default     = "aws"
}

variable "s3_bucket_name" {
  description = "Name of S3 Bucket"
  type        = string
  default     = "s3_bucket_name"
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "public_subnet_1_id" {
  description = "Id of first public subnet"
  type        = string
}

variable "public_subnet_2_id" {
  description = "Id of second public subnet"
  type        = string
}

variable "private_subnet_1_id" {
  description = "Id of first private subnet"
  type        = string
}

variable "private_subnet_2_id" {
  description = "Id of second private subnet"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of IAM instance profile"
  type        = string
}

variable "public_security_group_id" {
  description = "Id of public security group"
  type        = string
}

variable "private_security_group_id" {
  description = "Id of private security group"
  type        = string
}

variable "rds_address" {
  description = "The hostname of the RDS instance"
  type        = string
}

variable "rds_connect_string" {
  description = "Connection string for RDS instance used by psql"
  type        = string
}