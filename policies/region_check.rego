package main

# Comprehensive list of allowed SAMA/NESA regions
allowed_regions = {
    # AWS (UAE, Bahrain)
    "me-central-1", "me-south-1",
    # GCP (Dammam, Doha)
    "me-central2", "me-central1",
    # Azure (UAE, Qatar)
    "uaenorth", "uaecentral", "qatarcentral",
    # OCI (Jeddah, Riyadh)
    "me-jeddah-1", "me-riyadh-1"
}

# Check AWS provider region
deny[msg] {
	aws := input.provider.aws[_]
	region := aws.region
	is_string(region)
	not startswith(region, "var.")
	not allowed_regions[region]
	msg := sprintf("AWS provider region '%v' is not allowed. Must be in Gulf: %v", [region, allowed_regions])
}

# Check Google provider region
deny[msg] {
	gcp := input.provider.google[_]
	region := gcp.region
	is_string(region)
	not startswith(region, "var.")
	not allowed_regions[region]
	msg := sprintf("Google provider region '%v' is not allowed. Must be in Gulf: %v", [region, allowed_regions])
}

# Check Variable defaults (Generic)
deny[msg] {
	region_var := input.variable.region
	default_val := region_var.default
	not allowed_regions[default_val]
	msg := sprintf("Variable 'region' default value '%v' is not allowed. Must be in Gulf: %v", [default_val, allowed_regions])
}
