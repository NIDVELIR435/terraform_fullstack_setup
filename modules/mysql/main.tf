locals {
  filename = ".${terraform.workspace}.db.env"
}

data "local_sensitive_file" "env_file" {
  filename = local.filename
}

locals {
  username = regex("DB_USERNAME=([^\n]+)", data.local_sensitive_file.env_file.content)[0]
  password = regex("DB_PASSWORD=([^\n]+)", data.local_sensitive_file.env_file.content)[0]
}

resource "aws_security_group" "pipeline_security_group" {
  name        = "${terraform.workspace}_mysql_pipeline_sg"
  description = "Should be empty, but will be configured from pipeline to have access to execute migrations."
  vpc_id      = data.aws_vpc.default_vpc.id
}

resource "aws_db_parameter_group" "mysql_custom_parameter_groups" {
  name        = "${terraform.workspace}-mysql-custom-parameter-groups"
  family      = "mysql8.0"
  description = "Custom parameter groups for MySQL"

  parameter {
    name  = "max_connections"
    value = var.max_connections
    apply_method = "pending-reboot"
  }
}


resource "aws_db_instance" "mysql" {
  identifier           = "${terraform.workspace}-mysql"
  allocated_storage    = 20
  db_name              = "${terraform.workspace}_db"
  engine               = "mysql"
  engine_version       = "8.0.34"
  instance_class       = var.instance_class
  port                 = 3306
  username             = local.username
  password             = local.password
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [data.aws_security_group.default.id, aws_security_group.pipeline_security_group.id]
  parameter_group_name = aws_db_parameter_group.mysql_custom_parameter_groups.name  # Attach the custom parameter group
}
