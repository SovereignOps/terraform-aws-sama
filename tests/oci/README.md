# OCI Test Infrastructure

## Overview

Due to limited local emulation support for Oracle Cloud Infrastructure (OCI), testing primarily relies on:

1. **Static Analysis**: `terraform validate` and `terraform fmt`.
2. **Policy as Code**: `opa` (Open Policy Agent) or `checkov` for compliance checks.
3. **Integration Testing**: Running `terraform plan` against a non-production OCI compartment.

## Recommended Tools

- `checkov`: For scanning OCI Terraform code for security misconfigurations.
- `tflint`: For OCI provider-specific linting.
