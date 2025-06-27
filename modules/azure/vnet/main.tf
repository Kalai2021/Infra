// Azure Virtual Network (VNet) resources will be defined here 

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.environment}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address_space]

  tags = {
    Environment = var.environment
  }
}

# Public Subnet (for React app)
resource "azurerm_subnet" "public" {
  name                 = "${var.environment}-public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_address_prefix]
}

# Private Subnet (for Backend app)
resource "azurerm_subnet" "private" {
  name                 = "${var.environment}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnet_address_prefix]
}

# Private Subnet for PostgreSQL
resource "azurerm_subnet" "postgres" {
  name                 = "${var.environment}-postgres-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.postgres_subnet_address_prefix]

  # Enable service endpoints for PostgreSQL
  service_endpoints = ["Microsoft.Sql"]
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat" {
  name                = "${var.environment}-nat-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

# NAT Gateway
resource "azurerm_nat_gateway" "main" {
  name                = "${var.environment}-nat-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Standard"

  tags = {
    Environment = var.environment
  }
}

# NAT Gateway Public IP Association
resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# NAT Gateway Subnet Association (for private subnet)
resource "azurerm_subnet_nat_gateway_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

# NAT Gateway Subnet Association (for postgres subnet)
resource "azurerm_subnet_nat_gateway_association" "postgres" {
  subnet_id      = azurerm_subnet.postgres.id
  nat_gateway_id = azurerm_nat_gateway.main.id
} 