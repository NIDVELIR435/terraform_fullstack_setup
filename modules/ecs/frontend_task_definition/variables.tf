variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}
variable "repo_url" {
  description = "The name of the ECR repository"
  type        = string
}

variable "cpu" {
  type = number
}
variable "memory" {
  type = number
}
