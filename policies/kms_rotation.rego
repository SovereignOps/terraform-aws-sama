package main

deny[msg] {
	some name
	key := input.resource.aws_kms_key[name]
	not key.enable_key_rotation
	msg := sprintf("KMS Key '%v' does not have key rotation enabled.", [name])
}
