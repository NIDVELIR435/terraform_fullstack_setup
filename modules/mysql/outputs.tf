output "host" {
  value = split(":", aws_db_instance.mysql.endpoint)[0]
}
output "port" {
  value = aws_db_instance.mysql.port
}
output "username" {
  value = aws_db_instance.mysql.username
}
output "password" {
  value = aws_db_instance.mysql.password
  sensitive = true
}
output "database" {
  value = aws_db_instance.mysql.db_name
}
output "pipeline_security_group_arn" {
  value = aws_security_group.pipeline_security_group.arn
}
