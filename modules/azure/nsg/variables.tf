variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "postgres_subnet_id" {
  description = "ID of the PostgreSQL subnet"
  type        = string
}

variable "public_subnet_address_prefix" {
  description = "Address prefix for public subnet"
  type        = string
}

variable "private_subnet_address_prefix" {
  description = "Address prefix for private subnet"
  type        = string
} 