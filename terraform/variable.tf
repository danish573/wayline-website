  variable "aws_region" {
    description = "AWS Region to setup Server"
    type        = string
    default     = "ap-south-1"
  }

variable "ami_id" {
  description = "Ubuntu Image ID"
  type        = string
  default     = "ami-07f07a6e1060cd2a8" # Ubuntu 22.04 LTS (us-east-1)
}

variable "instance_type" {
  description = "Define EC-2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "key_name" {
  description = "EC-2 Instance Security key"
  type        = string
  default     = "Mumbai"
}
