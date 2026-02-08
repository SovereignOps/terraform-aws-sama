# SAMA Compliance Kit (Content Factory)

## Summary of Completed Work
I have generated 5 technical blog posts tailored for "Engineer to Engineer" consumption, focusing on SAMA/NESA compliance for AWS workloads in the Gulf.

### Artifacts Created
Directory: `sama-compliance-kit/content/`

1.  **[Infrastructure]** `01-aws-regions-comparison.md`
    - **Topic:** AWS Bahrain vs UAE vs Saudi regions.
    - **Key Tech:** Latency stats from Riyadh, Data Residency rules, BYOK strategy.
2.  **[Code]** `02-sama-compliant-s3.md`
    - **Topic:** Terraform module for SAMA-compliant S3.
    - **Key Tech:** KMS (CMK), Public Access Block, Versioning, Logging.
3.  **[Architecture]** `03-3-tier-vpc-architecture.md`
    - **Topic:** Network segmentation (DMZ, App, Data).
    - **Key Tech:** VPC design, Subnet isolation, Security Groups, Flow Logs.
4.  **[Dev]** `04-localization-rtl-hijri.md`
    - **Topic:** Frontend engineering for the Gulf.
    - **Key Tech:** CSS Logical Properties (RTL), `Intl.DateTimeFormat` (Hijri).
5.  **[Policy]** `05-automating-nesa-opa-tfsec.md`
    - **Topic:** Policy-as-Code for NESA/SAMA.
    - **Key Tech:** OPA (Rego), TFSec, CI/CD pipeline integration.

## Style Notes
- **Tone:** Direct, technical, no marketing fluff.
- **Format:** Markdown with Frontmatter (ready for Dev.to/Hugo/Jekyll).
- **Links:** All posts link back to `github.com/SovereignOps/terraform-aws-sama`.
