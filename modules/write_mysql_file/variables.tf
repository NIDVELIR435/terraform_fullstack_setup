variable "host" {
  description = "Generated db host"
  type        = string
}
variable "port" {
  description = "Generated db port"
  type        = number
}
variable "username" {
  description = "Generated db username"
  type        = string
}
variable "password" {
  description = "Generated db password"
  type        = string
  sensitive   = true
}
variable "database" {
  description = "Generated db database"
  type        = string
}
variable "bucket_name" {
  description = "Target bucket for db file"
  type        = string
}
variable "ecs_backend_database_env_file_path" {
  description = "Path for db file"
  type        = string
}
