variable "allowed_ecr_arn_list" {
  type        = list(string)
}
variable "allowed_ecs_arn_list" {
  type        = list(string)
}
variable "rds_security_group_arn_list" {
  type        = list(string)
}
variable "ecs_task_executions_arn_list" {
  type        = list(string)
}
