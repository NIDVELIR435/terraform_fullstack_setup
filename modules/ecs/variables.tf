variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}
variable "backend_api_repo_url" {
  description = "The name of the ECR repository"
  type        = string
}
variable "backend_cron_repo_url" {
  description = "The name of the ECR repository"
  type        = string
}
variable "frontend_repo_url" {
  description = "The name of the ECR repository"
  type        = string
}
variable "backend_api_env_file_arn" {
  description = "The arn path to the S3 env file"
  type        = string
}
variable "backend_cron_env_file_arn" {
  description = "The arn path to the S3 env file"
  type        = string
}
variable "backend_db_env_file_arn" {
  description = "The arn path to the S3 db env file"
  type        = string
}
# variable "backend_redis_env_file_arn" {
#   description = "The arn path to the S3 redis env file"
#   type        = string
# }

variable "desired_backend_api_instances_count" {
  type        = number
}
variable "desired_backend_cron_instances_count" {
  type        = number
}
variable "desired_frontend_instances_count" {
  type        = number
}
variable "backend_api_target_group_arn" {
  type        = string
}
variable "backend_cron_target_group_arn" {
  type        = string
}
variable "frontend_target_group_arn" {
  type        = string
}
variable "api_cpu" {
  type = number
}
variable "api_memory" {
  type = number
}
variable "cron_cpu" {
  type = number
}
variable "cron_memory" {
  type = number
}
variable "frontend_cpu" {
  type = number
}
variable "frontend_memory" {
  type = number
}
