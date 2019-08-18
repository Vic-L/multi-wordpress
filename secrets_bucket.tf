resource "aws_s3_bucket" "secrets_logging_bucket" {
  bucket = var.secrets_logging_bucket_name
  region = "us-east-1"
  acl = "log-delivery-write"
}

module "secrets_bucket" {
  source = "trussworks/s3-private-bucket/aws"
  bucket = var.secrets_bucket_name
  logging_bucket = var.secrets_logging_bucket_name
  use_account_alias_prefix = "true"
}