# terraform-aws-sama: The SAMA/NESA Compliance Kit for Gulf Tech

**Don't get fined. Deploy audit-ready infrastructure in KSA/UAE in 10 minutes.**

`terraform-aws-sama` is an opinionated, battle-tested Terraform library designed specifically for Fintechs, Healthcare, and Government entities in Saudi Arabia (SAMA) and the UAE (NESA/DESC). It implements strict data residency, encryption, and audit logging requirements out of the box.

## 🏗 Architecture

This kit deploys a **3-Tier Private Architecture** compliant with SAMA Cyber Security Framework.

```mermaid
graph TD
    subgraph "KSA Region (me-central-1)"
        subgraph "VPC (SAMA Compliant)"
            direction TB
            ALB[Application Load Balancer] --> |HTTPS/TLS 1.2| AppTier
            
            subgraph "Public Subnet (DMZ)"
                NAT[NAT Gateway]
                Bastion[Bastion Host / SSM]
            end
            
            subgraph "App Tier (Private)"
                AppTier[EC2 / EKS / Lambda]
            end
            
            subgraph "Data Tier (Private & Encrypted)"
                RDS[(RDS / Aurora)]
                S3[(S3 Private Buckets)]
            end
            
            AppTier --> RDS
            AppTier --> S3
        end
        
        KMS[AWS KMS (AES-256)] -.-> RDS
        KMS -.-> S3
        
        CloudTrail[CloudTrail Logs] --> S3Audit[Audit Bucket]
        Config[AWS Config] --> S3Audit
        GuardDuty[GuardDuty] --> SecurityHub
    end
```

## 🛡 Compliance Mapping (SAMA/NESA)

We map SAMA Cyber Security Framework controls directly to Terraform resources.

| Control ID | Description | Terraform Implementation | Module |
|------------|-------------|--------------------------|--------|
| **3.3.9.4** | Cryptographic Key Management | AWS KMS (AES-256) with automatic rotation. | `module.security` |
| **3.3.8.5** | Network Segmentation | VPC with strict Public/Private subnets, NACLs, and Security Groups. | `module.network` |
| **3.1.1.6** | Independent Audit Logs | CloudTrail, VPC Flow Logs, and S3 Server Access Logs enabled globally. | `module.security` |
| **3.3.15.4** | Incident Management Logs | Centralized logging bucket with MFA delete and object locking. | `module.data` |
| **3.3.5.7** | Access Control & MFA | IAM Policies with least privilege; Enforced MFA for console users. | `module.identity` |
| **3.3.3.1** | Asset Management | AWS Config rules for continuous compliance monitoring. | `module.security` |

> **Note:** See `sama_controls_matrix.csv` for the full mapping of 150+ controls.

## 🚀 Usage Guide

### Prerequisites
- Terraform >= 1.0.0
- AWS Account (me-central-1 for KSA or me-south-1 for UAE)

### Quick Start

Create a `main.tf` file:

```hcl
module "sama_stack" {
  source = "./sama-compliance-kit"

  # Project Details
  project_name = "fintech-core"
  environment  = "production"
  region       = "me-central-1" # Riyadh Data Residency

  # Network Configuration
  vpc_cidr = "10.10.0.0/16"

  # Compliance Settings
  enable_kms_rotation = true
  retention_days      = 365 # SAMA requires 1 year min
}
```

Run:
```bash
terraform init
terraform apply
```

## 🔒 Security Features
- **Data Residency:** Hardcoded region checks to prevent accidental deployment outside GCC.
- **Encryption Everywhere:** `AES-256` for S3, EBS, RDS. `TLS 1.2` enforced on Load Balancers.
- **Audit Ready:** Pre-configured AWS Config Rules for SAMA.

## 🤝 Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to add more controls.

## 📄 License
MIT License. See [LICENSE](LICENSE).
