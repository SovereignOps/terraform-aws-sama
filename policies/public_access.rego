package main

# --- AWS (RDS) ---
deny[msg] {
	some name
	db := input.resource.aws_db_instance[name]
	db.publicly_accessible == true
	msg := sprintf("AWS RDS Instance '%v' is publicly accessible. This is prohibited by SAMA regulations.", [name])
}

# --- GCP (Cloud SQL) ---
deny[msg] {
	some name
	instance := input.resource.google_sql_database_instance[name]
	settings := instance.settings
	ipv4 := settings.ip_configuration.ipv4_enabled
	ipv4 == true
	msg := sprintf("GCP Cloud SQL Instance '%v' has public IPv4 enabled. Only Private IP is allowed.", [name])
}

# --- Azure (PostgreSQL Flexible Server) ---
deny[msg] {
	some name
	server := input.resource.azurerm_postgresql_server[name]
	access := server.public_network_access_enabled
	access == true
	msg := sprintf("Azure PostgreSQL Server '%v' allows public network access. This is prohibited.", [name])
}

# --- OCI (Generic DB System - Example for future extension) ---
# OCI DB System public access is typically controlled via subnet placement (Public vs Private Subnet).
# For now, we enforce subnet visibility check if needed, but Terraform resource attributes vary.
# We will focus on the explicitly requested providers first.
