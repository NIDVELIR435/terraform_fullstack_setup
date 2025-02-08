output "backend_api_service_arn" {
  value = aws_ecs_service.backend_api.id
}
output "backend_api_task_execution_role_arn" {
  value = module.backend_api_task_definition.ecs_task_execution_role_arn
}

output "backend_cron_service_arn" {
  value = aws_ecs_service.backend_cron.id
}
output "backend_cron_task_execution_role_arn" {
  value = module.backend_cron_task_definition.ecs_task_execution_role_arn
}

output "frontend_service_arn" {
  value = aws_ecs_service.frontend.id
}
output "frontend_task_execution_role_arn" {
  value = module.frontend_task_definition.ecs_task_execution_role_arn
}
