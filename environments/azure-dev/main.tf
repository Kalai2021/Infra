# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.environment}-rg"
  location = var.location

  tags = {
    Environment = var.environment
  }
}

# Virtual Network and Networking
module "vnet" {
  source = "../../modules/azure/vnet"
  
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_address_space  = "10.0.0.0/16"
  public_subnet_address_prefix  = "10.0.1.0/24"
  private_subnet_address_prefix = "10.0.2.0/24"
  postgres_subnet_address_prefix = "10.0.3.0/24"
}

# Network Security Groups
module "nsg" {
  source = "../../modules/azure/nsg"
  
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  public_subnet_id   = module.vnet.public_subnet_id
  private_subnet_id  = module.vnet.private_subnet_id
  postgres_subnet_id = module.vnet.postgres_subnet_id
  
  public_subnet_address_prefix  = "10.0.1.0/24"
  private_subnet_address_prefix = "10.0.2.0/24"
}

# PostgreSQL Database
module "postgres" {
  source = "../../modules/azure/sql"
  
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_id             = module.vnet.vnet_id
  postgres_subnet_id  = module.vnet.postgres_subnet_id
  
  admin_username = var.postgres_admin_username
  admin_password = var.postgres_admin_password
  db_name        = var.postgres_db_name
  
  # For dev environment, use smaller instance
  sku_name = "B_Standard_B1ms"
  storage_mb = 32768
  
  # Disable high availability for dev
  high_availability_mode = "Disabled"
  geo_redundant_backup_enabled = false
}

# Example: App Service Plan for React App (would be deployed in public subnet)
# resource "azurerm_app_service_plan" "react" {
#   name                = "${var.environment}-react-asp"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   kind                = "Linux"
#   reserved            = true
# 
#   sku {
#     tier = "Basic"
#     size = "B1"
#   }
# 
#   tags = {
#     Environment = var.environment
#   }
# }

# Example: App Service for React App
# resource "azurerm_app_service" "react" {
#   name                = "${var.environment}-react-app"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   app_service_plan_id = azurerm_app_service_plan.react.id
# 
#   site_config {
#     linux_fx_version = "NODE|16-lts"
#   }
# 
#   app_settings = {
#     "REACT_APP_API_URL" = "https://${var.environment}-backend-app.azurewebsites.net"
#   }
# 
#   tags = {
#     Environment = var.environment
#   }
# }

# Example: App Service Plan for Backend App (would be deployed in private subnet)
# resource "azurerm_app_service_plan" "backend" {
#   name                = "${var.environment}-backend-asp"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   kind                = "Linux"
#   reserved            = true
# 
#   sku {
#     tier = "Basic"
#     size = "B1"
#   }
# 
#   tags = {
#     Environment = var.environment
#   }
# }

# Example: App Service for Backend App
# resource "azurerm_app_service" "backend" {
#   name                = "${var.environment}-backend-app"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   app_service_plan_id = azurerm_app_service_plan.backend.id
# 
#   site_config {
#     linux_fx_version = "NODE|16-lts"
#   }
# 
#   app_settings = {
#     "DB_HOST"     = module.postgres.postgres_server_fqdn
#     "DB_PORT"     = "5432"
#     "DB_NAME"     = module.postgres.postgres_database_name
#     "DB_USERNAME" = var.postgres_admin_username
#     "DB_PASSWORD" = var.postgres_admin_password
#   }
# 
#   tags = {
#     Environment = var.environment
#   }
# } 