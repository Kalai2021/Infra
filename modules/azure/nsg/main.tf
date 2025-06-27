# Network Security Group for React App (Public)
resource "azurerm_network_security_group" "react" {
  name                = "${var.environment}-react-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTPS (443) from anywhere
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP (80) from anywhere (for redirects)
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow all outbound traffic
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
  }
}

# Network Security Group for Backend App (Private)
resource "azurerm_network_security_group" "backend" {
  name                = "${var.environment}-backend-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTPS (443) only from React app subnet
  security_rule {
    name                       = "AllowHTTPSFromReact"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.public_subnet_address_prefix
    destination_address_prefix = "*"
  }

  # Allow all outbound traffic
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
  }
}

# Network Security Group for PostgreSQL
resource "azurerm_network_security_group" "postgres" {
  name                = "${var.environment}-postgres-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow PostgreSQL (5432) only from Backend app subnet
  security_rule {
    name                       = "AllowPostgreSQLFromBackend"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.private_subnet_address_prefix
    destination_address_prefix = "*"
  }

  # No outbound rules needed for PostgreSQL

  tags = {
    Environment = var.environment
  }
}

# Associate NSG with public subnet (React app)
resource "azurerm_subnet_network_security_group_association" "react" {
  subnet_id                 = var.public_subnet_id
  network_security_group_id = azurerm_network_security_group.react.id
}

# Associate NSG with private subnet (Backend app)
resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = var.private_subnet_id
  network_security_group_id = azurerm_network_security_group.backend.id
}

# Associate NSG with postgres subnet
resource "azurerm_subnet_network_security_group_association" "postgres" {
  subnet_id                 = var.postgres_subnet_id
  network_security_group_id = azurerm_network_security_group.postgres.id
} 