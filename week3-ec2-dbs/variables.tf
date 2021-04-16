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

variable "rds_allocated_storage" {
  description = "Storage allocated to PostgreSQL database instance"
  type        = number
  default     = 10
}

variable "postgres_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "12.5"
}

variable "rds_instance_type" {
  description = "Instance type for database instance"
  type        = string
  default     = "db.t2.micro"
}

variable "rds_username" {
  description = "Database username"
  type        = string
  default     = "postgres"
}

variable "rds_password" {
  description = "Database password"
  type        = string
  default     = "postgres"
}

variable "rds_port" {
  description = "Port on which database will accept connections"
  type        = number
  default     = 5432
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "aws_services"
}
