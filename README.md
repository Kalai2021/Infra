# Multi-Cloud Infrastructure with Terraform

This repository contains Terraform configurations for deploying infrastructure across multiple cloud providers (AWS and Azure) with a focus on security, scalability, and best practices.

## 🏗️ Architecture Overview

### AWS Architecture
```
Internet → React App (Public Subnet) → Backend App (Private Subnet) → RDS PostgreSQL (Private Subnet)
```

### Azure Architecture
```
Internet → React App (Public Subnet) → Backend App (Private Subnet) → Azure PostgreSQL (Private Subnet)
```

## 📁 Project Structure

```
Infra/
├── environments/
│   ├── dev/                    # AWS Development Environment
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── staging/                # AWS Staging Environment
│   ├── prod/                   # AWS Production Environment
│   └── azure-dev/              # Azure Development Environment
│       ├── main.tf
│       └── variables.tf
├── modules/
│   ├── aws/                    # AWS Infrastructure Modules
│   │   ├── vpc/               # Virtual Private Cloud
│   │   ├── security/          # Security Groups
│   │   ├── rds/               # PostgreSQL Database
│   │   └── ecs/               # Container Orchestration
│   └── azure/                  # Azure Infrastructure Modules
│       ├── vnet/              # Virtual Network
│       ├── nsg/               # Network Security Groups
│       ├── sql/               # PostgreSQL Database
│       └── aks/               # Kubernetes Service
├── global/                     # Global Provider Configuration
│   └── providers.tf
├── providers.tf               # Root Provider Configuration
├── backend.tf                 # Remote State Configuration
└── README.md
```

## 🔒 Security Model

### Network Security
- **Public Subnets**: Only for frontend applications (React)
- **Private Subnets**: For backend applications and databases
- **Restricted Access**: Backend only accessible via HTTPS (443) from frontend
- **Database Isolation**: Databases only accessible from backend applications

### Security Groups (AWS) / Network Security Groups (Azure)
- **Frontend**: Allows HTTPS (443) and HTTP (80) from internet
- **Backend**: Allows HTTPS (443) only from frontend subnet
- **Database**: Allows PostgreSQL (5432) only from backend subnet

## 🚀 Quick Start

### Prerequisites

1. **Install Terraform** (v1.0+)
   ```bash
   # macOS with Homebrew
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   
   # Or download from https://developer.hashicorp.com/terraform/downloads
   ```

2. **Configure Cloud Credentials**

   **AWS:**
   ```bash
   aws configure
   # Enter your Access Key ID, Secret Access Key, Region
   ```

   **Azure:**
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

### Deploy AWS Infrastructure

1. **Navigate to AWS environment:**
   ```bash
   cd environments/dev
   ```

2. **Create terraform.tfvars:**
   ```hcl
   db_password = "your-secure-password"
   availability_zone = "us-west-2a"
   ```

3. **Initialize and deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Deploy Azure Infrastructure

1. **Navigate to Azure environment:**
   ```bash
   cd environments/azure-dev
   ```

2. **Create terraform.tfvars:**
   ```hcl
   postgres_admin_password = "your-secure-password"
   location = "East US"
   ```

3. **Initialize and deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## 📋 Infrastructure Components

### AWS Components
- **VPC**: Custom Virtual Private Cloud with public/private subnets
- **Security Groups**: Network-level security rules
- **RDS PostgreSQL**: Managed PostgreSQL database
- **NAT Gateway**: Internet access for private resources
- **Internet Gateway**: Internet access for public resources

### Azure Components
- **Virtual Network**: Custom VNet with public/private subnets
- **Network Security Groups**: Network-level security rules
- **Azure PostgreSQL**: Managed PostgreSQL Flexible Server
- **NAT Gateway**: Internet access for private resources
- **Private Endpoints**: Secure database access

## 🔧 Module Configuration

### VPC/VNet Module
```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  environment         = "dev"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone  = "us-west-2a"
}
```

### Security Module
```hcl
module "security" {
  source = "../../modules/aws/security"
  
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
}
```

### Database Module
```hcl
module "rds" {
  source = "../../modules/aws/rds"
  
  environment        = "dev"
  subnet_ids         = [module.vpc.rds_subnet_id]
  security_group_ids = [module.security.rds_security_group_id]
  
  db_name     = "myapp_dev"
  db_username = "postgres"
  db_password = var.db_password
}
```

## 🛡️ Security Best Practices

1. **Network Segmentation**: Separate public and private resources
2. **Least Privilege**: Minimal required access between components
3. **Encryption**: All data encrypted at rest and in transit
4. **Private Endpoints**: Database access through private networks only
5. **Security Groups**: Restrictive network access rules

## 🔄 State Management

### Remote State Configuration
Configure remote state storage for team collaboration:

**AWS S3 Backend:**
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "us-west-2"
  }
}
```

**Azure Storage Backend:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

## 🧹 Cleanup

### Destroy Infrastructure
```bash
# AWS
cd environments/dev
terraform destroy

# Azure
cd environments/azure-dev
terraform destroy
```

## 📝 Contributing

1. Create a feature branch
2. Make your changes
3. Test with `terraform plan`
4. Submit a pull request

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## ⚠️ Important Notes

- **Never commit sensitive data** like passwords or API keys
- **Use remote state storage** for team collaboration
- **Test changes in dev/staging** before production
- **Review security groups** and network access rules regularly
- **Monitor costs** and clean up unused resources

## 🆘 Troubleshooting

### Common Issues

1. **Provider Version Conflicts**: Update provider versions in `versions.tf`
2. **State Lock Issues**: Check for concurrent operations
3. **Permission Errors**: Verify cloud provider credentials
4. **Network Connectivity**: Check security group rules

### Getting Help

- Check Terraform logs: `terraform logs`
- Validate configuration: `terraform validate`
- Format code: `terraform fmt`
- Check syntax: `terraform plan`

---

**Happy Infrastructure as Code! 🚀** 