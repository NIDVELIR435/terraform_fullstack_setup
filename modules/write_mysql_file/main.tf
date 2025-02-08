locals {
  db_content = <<EOF
DB_HOST=${var.host}
DB_PORT=${var.port}
DB_USERNAME=${var.username}
DB_PASSWORD=${var.password}
DB_DATABASE=${var.database}
   EOF
}

resource "local_file" "env_file" {
  filename = "${path.module}/../../.${terraform.workspace}.db.env"
  content  = local.db_content
}

# Upload the .env file to S3
resource "aws_s3_object" "backend_env_file" {
  bucket = var.bucket_name
  key    = var.ecs_backend_database_env_file_path
  acl    = "private"
  content  = local.db_content
}
