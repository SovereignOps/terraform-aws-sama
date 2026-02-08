---
title: "The 3-Tier Private VPC for Gulf Fintechs: A SAMA-Compliant Architecture"
published: false
description: "Designing a segmented, secure network architecture (DMZ, App, Data) for financial applications in AWS Middle East regions."
tags: vpc, aws, architecture, fintech, networking
---

# The 3-Tier Private VPC for Gulf Fintechs

When designing for SAMA compliance, network segmentation is not optional. A "flat" VPC where your database sits alongside your web server is an immediate red flag.

The industry standard is the **3-Tier Architecture**: DMZ, Application Layer, and Data Layer.

## The Layers

### 1. DMZ (Public Subnets)
- **Purpose:** Public-facing entry points.
- **Components:** Application Load Balancers (ALB), NAT Gateways, Bastion Hosts.
- **Access:** Internet Gateway (IGW) attached.
- **Security Group:** Inbound 443 (HTTPS) from 0.0.0.0/0.

### 2. Application Layer (Private Subnets)
- **Purpose:** Where the business logic lives.
- **Components:** EC2 instances, EKS Nodes, Lambda (in VPC).
- **Access:** Outbound via NAT Gateway (for updates/APIs). NO direct inbound from internet.
- **Security Group:** Inbound only from DMZ ALB Security Group.

### 3. Data Layer (Isolated Subnets)
- **Purpose:** The crown jewels.
- **Components:** RDS (Postgres/Aurora), ElastiCache (Redis), Redshift.
- **Access:** NO Internet Access. NO NAT Gateway access. Only reachable from Application Layer.
- **Security Group:** Inbound 5432 (Postgres) only from App Layer Security Group.

## Terraform Implementation

This is how we define the network boundaries in code.

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "fintech-prod-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["me-south-1a", "me-south-1b", "me-south-1c"]
  
  # 1. DMZ (Public)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
  # 2. App Layer (Private with NAT)
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  # 3. Data Layer (Isolated - No NAT)
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false # HA Required for Prod
  
  # Compliance: Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}
```

## Security Group Logic (The Firewall)

The real security happens here. Never use `0.0.0.0/0` in internal layers.

```hcl
# App Layer SG
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Reference, not CIDR
  }
}

# Data Layer SG
resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Allow traffic from App only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id] # Chained reference
  }
}
```

## Why This Matters
If an attacker compromises your web server (App Layer), they still face a hard firewall to reach the database. Without the correct SSH key or credentials, lateral movement is blocked by the network architecture itself.

---
*Repo:* [github.com/SovereignOps/terraform-aws-sama](https://github.com/SovereignOps/terraform-aws-sama)
