---
title: "Automating NESA Compliance with OPA/TFSec"
published: false
description: "How to enforce NESA (UAE) and SAMA (KSA) compliance rules as code using OPA (Open Policy Agent) and TFSec in your CI/CD pipeline."
tags: compliance, devsecops, opa, tfsec, nesa
---

# Automating NESA Compliance with OPA/TFSec

Compliance documents are PDFs. Your infrastructure is code. The gap between them is where security failures happen. To satisfy **NESA (UAE)** and **SAMA (KSA)**, you must shift compliance left—into the pull request.

Here is how to automate policy checks.

## 1. Static Analysis with TFSec

TFSec scans your Terraform code *before* deployment. It catches common misconfigurations like unencrypted storage or open security groups.

### Running a Scan
```bash
tfsec . --concise-output
```

### Handling False Positives (The Right Way)
Sometimes you *need* a public bucket (e.g., static assets). Document the exception inline.

```hcl
# tfsec:ignore:aws-s3-no-public-access-block
resource "aws_s3_bucket" "public_assets" {
  bucket = "company-public-assets"
  # ...
}
```

## 2. Custom Policy with OPA (Rego)

For specific regional rules (e.g., "All resources must be in Bahrain"), you need **Open Policy Agent (OPA)**.

### The Policy File (`policy.rego`)

This rule fails the build if any resource is created outside `me-south-1` (Bahrain) or `me-central-1` (UAE).

```rego
package terraform.analysis

import input as tfplan

# Allowed regions for data residency
allowed_regions = ["me-south-1", "me-central-1"]

deny[msg] {
  resource := tfplan.resource_changes[_]
  region := resource.change.after.region
  
  # Check if region is in allowed list
  not region_is_allowed(region)

  msg := sprintf(
    "Resource '%s' is in region '%s'. Only %v are allowed for compliance.",
    [resource.address, region, allowed_regions]
  )
}

region_is_allowed(r) {
  r == allowed_regions[_]
}
```

### Validating the Plan
1.  Generate Terraform plan JSON:
    ```bash
    terraform plan -out=tfplan
    terraform show -json tfplan > tfplan.json
    ```
2.  Check against OPA policy:
    ```bash
    opa eval --input tfplan.json --data policy.rego "data.terraform.analysis.deny"
    ```

## 3. The CI/CD Pipeline (GitHub Actions)

Add this to your workflow to block non-compliant PRs.

```yaml
steps:
  - name: Run TFSec
    uses: aquasecurity/tfsec-action@v1.0.0
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }}

  - name: OPA Compliance Check
    run: |
      terraform plan -out=tfplan
      terraform show -json tfplan > tfplan.json
      # Fail if any deny rules match
      result=$(opa eval --input tfplan.json --data policy.rego "data.terraform.analysis.deny" | jq '.result[0].expressions[0].value')
      if [ "$result" != "[]" ]; then
        echo "Compliance Check Failed: $result"
        exit 1
      fi
```

## Conclusion
Manual audits are too slow. By embedding NESA/SAMA rules into the pipeline, you guarantee that **every merged PR is compliant by definition**.

---
*Repo:* [github.com/SovereignOps/terraform-aws-sama](https://github.com/SovereignOps/terraform-aws-sama)
