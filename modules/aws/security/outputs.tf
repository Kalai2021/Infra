output "react_security_group_id" {
  description = "ID of the React app security group"
  value       = aws_security_group.react.id
}

output "backend_security_group_id" {
  description = "ID of the Backend app security group"
  value       = aws_security_group.backend.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
} 