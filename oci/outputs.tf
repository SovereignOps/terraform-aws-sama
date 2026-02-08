output "vcn_id" {
  value = oci_core_vcn.vcn.id
}

output "bucket_id" {
  value = oci_objectstorage_bucket.bucket.bucket_id
}
