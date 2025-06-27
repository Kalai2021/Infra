// Azure SQL-specific variables will be defined here 
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

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "postgres_subnet_id" {
  description = "ID of the PostgreSQL subnet"
  type        = string
}

variable "pg_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "14"
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}

variable "sku_name" {
  description = "SKU name for the server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "backup_retention_days" {
  description = "Backup retention days"
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}

variable "high_availability_mode" {
  description = "High availability mode"
  type        = string
  default     = "Disabled"
}

variable "maintenance_window_day" {
  description = "Maintenance window day"
  type        = number
  default     = 0
}

variable "maintenance_window_start_hour" {
  description = "Maintenance window start hour"
  type        = number
  default     = 2
}

variable "maintenance_window_start_minute" {
  description = "Maintenance window start minute"
  type        = number
  default     = 0
} 