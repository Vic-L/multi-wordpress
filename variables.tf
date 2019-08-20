variable "project_name" {
  type = string
  default = "multi_wordpress"
}

variable "availability_zone" {
  type = string
  default = "us-east-1a"
}

variable "aws_ebs_volume" {
  type = map
  default = {
    size = 16
  }
}

variable "secrets_bucket_name" {
  type = string
  default = "multi-wordpress-secrets-bucket"
}

variable "secrets_logging_bucket_name" {
  type = string
  default = "multi-wordpress-secrets-logging-bucket"
}

variable "multi_wordpress_repository" {
  type = string
  default = ""
}