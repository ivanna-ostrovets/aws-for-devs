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
