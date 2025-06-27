// Azure SQL Database resources will be defined here 

# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
  }
}

# Private DNS Zone Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${var.environment}-postgres-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = {
    Environment = var.environment
  }
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.environment}-postgres"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.pg_version
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  storage_mb             = var.storage_mb
  sku_name               = var.sku_name

  # Network configuration
  delegated_subnet_id = var.postgres_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id

  # Backup configuration
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  # High availability
  high_availability {
    mode = var.high_availability_mode
  }

  # Maintenance window
  maintenance_window {
    day_of_week  = var.maintenance_window_day
    start_hour   = var.maintenance_window_start_hour
    start_minute = var.maintenance_window_start_minute
  }

  tags = {
    Environment = var.environment
  }
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Private Endpoint for PostgreSQL
resource "azurerm_private_endpoint" "postgres" {
  name                = "${var.environment}-postgres-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.postgres_subnet_id

  private_service_connection {
    name                           = "${var.environment}-postgres-psc"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "${var.environment}-postgres-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }

  tags = {
    Environment = var.environment
  }
} 