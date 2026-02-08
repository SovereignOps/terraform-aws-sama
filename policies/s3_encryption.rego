package main

deny[msg] {
	some name
	bucket := input.resource.aws_s3_bucket[name]
	not bucket_encrypted(name)
	msg := sprintf("S3 Bucket '%v' is not encrypted (missing server_side_encryption_configuration).", [name])
}

# Check inline block
bucket_encrypted(name) {
	bucket := input.resource.aws_s3_bucket[name]
	bucket.server_side_encryption_configuration
}

# Check separate resource
bucket_encrypted(name) {
	encryption := input.resource.aws_s3_bucket_server_side_encryption_configuration[_]
	contains(encryption.bucket, sprintf("aws_s3_bucket.%v", [name]))
}
