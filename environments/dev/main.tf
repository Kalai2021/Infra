provider "aws" {
  region = "us-east-1"
}

# VPC and Networking
module "vpc" {
  source = "../../modules/aws/vpc"
  
  environment         = "dev"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  rds_subnet_cidr    = "10.0.3.0/24"
  availability_zone  = "us-west-2a"
}

# Security Groups
module "security" {
  source = "../../modules/aws/security"
  
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
}

# RDS PostgreSQL
module "rds" {
  source = "../../modules/aws/rds"
  
  environment        = "dev"
  subnet_ids         = [module.vpc.rds_subnet_id]
  security_group_ids = [module.security.rds_security_group_id]
  
  db_name     = "myapp_dev"
  db_username = "postgres"
  db_password = var.db_password
  
  # For dev environment, use smaller instance
  instance_class = "db.t3.micro"
  allocated_storage = 20
  
  # Disable deletion protection for dev
  deletion_protection = false
  skip_final_snapshot = true
}

# ECR Repositories
resource "aws_ecr_repository" "go_backend" {
  name = "go-backend"
}
resource "aws_ecr_repository" "react_frontend" {
  name = "react-frontend"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "main-cluster"
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definitions (Go backend and React frontend)
resource "aws_ecs_task_definition" "go_backend" {
  family                   = "go-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions    = jsonencode([
    {
      name      = "go-backend"
      image     = "<your-go-backend-ecr-image-uri>:latest"
      portMappings = [{ containerPort = 8080 }]
      environment = [
        { name = "DB_HOST", value = module.rds.db_endpoint },
        { name = "DB_PORT", value = "5432" },
        { name = "DB_NAME", value = module.rds.db_name },
        { name = "DB_USERNAME", value = module.rds.db_username },
        { name = "DB_PASSWORD", value = var.db_password },
        { name = "SERVER_PORT", value = "8080" },
        { name = "LOG_LEVEL", value = "info" }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "react_frontend" {
  family                   = "react-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions    = jsonencode([
    {
      name      = "react-frontend"
      image     = "<your-react-frontend-ecr-image-uri>:latest"
      portMappings = [{ containerPort = 80 }]
      environment = [
        { name = "REACT_APP_API_URL", value = "http://${module.rds.db_endpoint}:8080" }
      ]
    }
  ])
}

# ECS Services (one for each app)
resource "aws_ecs_service" "go_backend" {
  name            = "go-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.go_backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [module.vpc.public_subnet_id]
    security_groups  = [module.security.ecs_security_group_id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "react_frontend" {
  name            = "react-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.react_frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [module.vpc.public_subnet_id]
    security_groups  = [module.security.ecs_security_group_id]
    assign_public_ip = true
  }
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
output "go_backend_service" {
  value = aws_ecs_service.go_backend.id
}
output "react_frontend_service" {
  value = aws_ecs_service.react_frontend.id
} 