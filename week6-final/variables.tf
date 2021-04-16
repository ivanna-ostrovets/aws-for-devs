variable "vpc_cidr" {
  description = "CIDR notation of VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR notation of first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR notation of first public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR notation of first private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR notation of first private subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "dynamodb_table_name"
}

variable "dynamodb_table_hash_key" {
  description = "DynamoDB table hash key"
  type        = string
  default     = "UserName"
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
  default     = "username"
}

variable "rds_password" {
  description = "Database password"
  type        = string
  default     = "password"
}

variable "rds_port" {
  description = "Port on which database will accept connections"
  type        = number
  default     = 5432
}
