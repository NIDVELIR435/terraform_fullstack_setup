variable "bucket_name" {
  description = "The name of the bucket for env files"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.bucket_name))
    error_message = "The bucket name must be between 3 and 63 characters long, and can contain only lowercase letters, numbers, hyphens, and periods."
  }
}

variable "backend_file_path" {
  description = "The file path for backend file"
  type        = string
}

variable "backend_initial_source_file_path" {
  description = "The file path for initial backend file"
  type        = string
}

resource "aws_s3_bucket" "env_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "backend_env" {
  bucket = aws_s3_bucket.env_bucket.bucket
  key    = var.backend_file_path
  source = var.backend_initial_source_file_path
}
