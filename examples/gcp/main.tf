# GCP Example Usage

module "gcp_compliance" {
  source = "../../gcp"

  project_id       = "my-gcp-project"
  region           = "me-central2"
  network_name     = "example-vpc"
  db_instance_name = "example-db"
  bucket_name      = "example-bucket"
  kms_key_name     = "projects/my-gcp-project/locations/me-central2/keyRings/my-ring/cryptoKeys/my-key"
}
