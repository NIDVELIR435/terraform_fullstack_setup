output "domain" {
  value = {
    name      = local.parsed_configs_from_file.domain_name
  }
}

output "ecs" {
  value = {
    desired_api_instances_count      = local.parsed_configs_from_file.ecs_desired_api_instances_count
    desired_cron_instances_count     = local.parsed_configs_from_file.ecs_desired_cron_instances_count
    desired_frontend_instances_count = local.parsed_configs_from_file.ecs_desired_frontend_instances_count
    api_cpu                      = local.parsed_configs_from_file.ecs_api_cpu
    api_memory                   = local.parsed_configs_from_file.ecs_api_memory
    cron_cpu                     = local.parsed_configs_from_file.ecs_cron_cpu
    cron_memory                  = local.parsed_configs_from_file.ecs_cron_memory
    frontend_cpu                 = local.parsed_configs_from_file.ecs_frontend_cpu
    frontend_memory              = local.parsed_configs_from_file.ecs_frontend_memory
  }
}

output "ecr" {
  value = {
    backend_api_max_images_count      = local.parsed_configs_from_file.ecr_backend_api_max_images_count
    backend_cron_max_images_count     = local.parsed_configs_from_file.ecr_backend_cron_max_images_count
    frontend_max_images_count         = local.parsed_configs_from_file.ecr_frontend_max_images_count
  }
}

output "s3_env" {
  value = local.s3_env
}

output "mysql" {
  value = {
    max_connections      = local.parsed_configs_from_file.mysql_max_connections
    instance_class      = local.parsed_configs_from_file.mysql_instance_class
  }
}
