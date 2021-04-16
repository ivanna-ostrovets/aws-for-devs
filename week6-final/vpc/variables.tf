variable "vpc_cidr" {
  description = "CIDR notation of VPC"
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR notation of first public subnet"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR notation of first public subnet"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR notation of first private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR notation of first private subnet"
  type        = string
}

variable "nat_instance_id" {
  description = "Id of NAT EC2 instance"
  type        = string
}