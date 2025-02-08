variable "host" {
  description = "Generated redis host"
  type        = string
}
variable "port" {
  description = "Generated redis port"
  type        = number
}
variable "bucket_name" {
  description = "Target bucket for db file"
  type        = string
}
variable "ecs_backend_redis_env_file_path" {
  description = "Path for db file"
  type        = string
}
