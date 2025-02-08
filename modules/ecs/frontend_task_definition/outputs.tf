output "task_definition_arn" {
  value = aws_ecs_task_definition.frontend.arn
}
output "container_name" {
  value = local.container_name
}
output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
