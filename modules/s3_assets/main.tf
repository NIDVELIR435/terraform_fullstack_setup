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

resource "aws_s3_bucket" "file_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.file_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_object" "logo" {
  bucket = aws_s3_bucket.file_bucket.bucket
  key    = var.backend_file_path
  source = var.backend_initial_source_file_path
}

# S3 Bucket Policy allowing CloudFront access
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.file_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"] # Grant access to anyone (public access)
    }
  }
}

resource "aws_s3_bucket_policy" "file_storage_policy" {
  bucket = aws_s3_bucket.file_bucket.id

  policy = data.aws_iam_policy_document.s3_policy.json
}
