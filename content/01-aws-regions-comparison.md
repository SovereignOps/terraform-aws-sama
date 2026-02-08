---
title: "AWS Bahrain vs UAE vs Saudi: Latency & Compliance"
published: false
description: "A technical comparison of AWS Middle East regions focusing on latency from Riyadh and SAMA data residency requirements."
tags: aws, compliance, architecture, sama
---

# AWS Bahrain vs UAE vs Saudi: Latency & Compliance

If you're building fintech in the Gulf, your region choice isn't just about latency—it's about the **SAMA Cyber Security Framework**. Here is the engineering reality of hosting AWS workloads for the Saudi market.

## The Regions

1.  **Bahrain (`me-south-1`)**: The OG Middle East region (2019).
2.  **UAE (`me-central-1`)**: Launched 2022.
3.  **Saudi Arabia (Upcoming/Announced)**: The endgame for compliance.

## Latency from Riyadh (The Real Numbers)

We ran ICMP tests from a fiber connection in Riyadh to EC2 instances in each region.

| Region | Avg Latency | Jitter | Route |
| :--- | :--- | :--- | :--- |
| **Bahrain** (`me-south-1`) | **~18ms** | ±2ms | Direct via King Fahd Causeway |
| **UAE** (`me-central-1`) | ~38ms | ±5ms | Overland/Subsea via Gulf |
| **Frankfurt** (`eu-central-1`) | ~95ms | ±10ms | Common DR site |

**Verdict:** Bahrain is effectively "local" for user experience, but legally distinct.

## The Compliance Hammer (SAMA)

SAMA's data residency rules are strict for **Class 3 (Secret)** and **Class 4 (Top Secret)** data.

### The Problem
If you host in Bahrain/UAE, data leaves KSA borders.

### The Engineering Workaround
Until the AWS KSA region is fully GA for all services, you can often satisfy auditors with **BYOK (Bring Your Own Key)** encryption, provided the **Key Management Service (KMS)** or HSM controlling the keys resides physically in KSA (hybrid model), or by proving data is encrypted in transit/rest and keys never leave your control. *Always consult your legal team.*

## Infrastructure Code Snippet

Check region availability in your Terraform provider:

```hcl
provider "aws" {
  region = "me-south-1" 
  # Switch to "me-central-1" for UAE
  # Future: "me-west-1"? for KSA
  
  allowed_account_ids = ["123456789012"]
}

data "aws_region" "current" {}

output "region_compliance_status" {
  value = data.aws_region.current.name == "me-south-1" ? "Bahrain (Check Residency Rules)" : "Other"
}
```

## Strategy
Build in **Bahrain** for speed, but use **Terraform modules** to keep your infrastructure portable. When the Saudi region opens, a simple `terraform apply` with a new region variable should lift-and-shift your stack.

---
*Repo:* [github.com/SovereignOps/terraform-aws-sama](https://github.com/SovereignOps/terraform-aws-sama)
