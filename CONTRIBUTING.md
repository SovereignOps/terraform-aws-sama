# Contributing to terraform-aws-sama

We welcome contributions! This project aims to simplify compliance for developers in the Gulf region.

## How to Contribute

1. **Fork the repo.**
2. **Create a branch** for your feature or fix (`git checkout -b feature/new-control-mapping`).
3. **Map the Control:** If you are adding a new resource, ensure it maps to a specific SAMA or NESA control. Update `sama_controls_matrix.csv` if necessary.
4. **Test your changes:** Run `terraform validate` and `tflint`.
5. **Submit a Pull Request.**

## Standards
- Use `snake_case` for resource names.
- Always include `description` for variables.
- Ensure all S3 buckets have encryption and versioning enabled by default.
