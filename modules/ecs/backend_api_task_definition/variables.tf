variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}
variable "repo_url" {
  description = "The name of the ECR repository"
  type        = string
}
variable "env_file_arn" {
  description = "The arn path to the S3 env file"
  type        = string
}
variable "db_env_file_arn" {
  description = "The arn path to the S3 db env file"
  type        = string
}
# variable "redis_env_file_arn" {
#   description = "The arn path to the S3 redis env file"
#   type        = string
# }

variable "cpu" {
  type = number
}
variable "memory" {
  type = number
}
