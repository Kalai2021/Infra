# Security Group for React App (Public)
resource "aws_security_group" "react" {
  name        = "${var.environment}-react-sg"
  description = "Security group for React application"
  vpc_id      = var.vpc_id

  # Allow HTTPS (443) from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (80) from anywhere (for redirects)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-react-sg"
  }
}

# Security Group for Backend App (Private)
resource "aws_security_group" "backend" {
  name        = "${var.environment}-backend-sg"
  description = "Security group for Backend application"
  vpc_id      = var.vpc_id

  # Allow HTTPS (443) only from React app security group
  ingress {
    description     = "HTTPS from React app"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.react.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-backend-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # Allow PostgreSQL (5432) only from Backend app security group
  ingress {
    description     = "PostgreSQL from Backend app"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  # No outbound rules needed for RDS

  tags = {
    Name = "${var.environment}-rds-sg"
  }
} 