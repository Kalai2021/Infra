// Azure VNet-specific variables will be defined here 

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_address_prefix" {
  description = "Address prefix for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_address_prefix" {
  description = "Address prefix for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "postgres_subnet_address_prefix" {
  description = "Address prefix for PostgreSQL subnet"
  type        = string
  default     = "10.0.3.0/24"
} 