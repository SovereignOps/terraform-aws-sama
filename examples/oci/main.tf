# OCI Example Usage

module "oci_compliance" {
  source = "../../oci"

  compartment_id   = "ocid1.compartment.oc1..aaaaaaa..."
  region           = "me-jeddah-1"
  vcn_name         = "example-vcn"
  bucket_name      = "example-bucket"
  bucket_namespace = "example-namespace"
  kms_key_id       = "ocid1.key.oc1..aaaaaaa..."
}
