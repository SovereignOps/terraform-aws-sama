# AWS Compliance Module

This directory contains the original SAMA-compliant AWS infrastructure code.

## Usage

See the root README for general information.
To use this module directly:

```hcl
module "sama_aws" {
  source = "./sama-compliance-kit/aws"
  
  region       = "me-central-1"
  project_name = "my-project"
  # ... other variables
}
```

Or run directly:
```bash
terraform init
terraform apply
```
