// AWS VPC-specific variables will be defined here 

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "rds_subnet_cidr" {
  description = "CIDR block for RDS subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
} 