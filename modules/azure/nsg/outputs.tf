output "react_nsg_id" {
  description = "ID of the React app network security group"
  value       = azurerm_network_security_group.react.id
}

output "backend_nsg_id" {
  description = "ID of the Backend app network security group"
  value       = azurerm_network_security_group.backend.id
}

output "postgres_nsg_id" {
  description = "ID of the PostgreSQL network security group"
  value       = azurerm_network_security_group.postgres.id
} 