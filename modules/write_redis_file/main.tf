locals {
  db_content = <<EOF
REDIS_HOST=${var.host}
REDIS_PORT=${var.port}
   EOF
}

resource "local_file" "env_file" {
  filename = "${path.module}/../../.${terraform.workspace}.redis.env"
  content  = local.db_content
}

# Upload the .env file to S3
resource "aws_s3_object" "backend_env_file" {
  bucket = var.bucket_name
  key    = var.ecs_backend_redis_env_file_path
  acl    = "private"
  content  = local.db_content
}
