resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# backend api
module "backend_api_task_definition" {
  source = "./backend_api_task_definition"
  repo_url = var.backend_api_repo_url
  env_file_arn = var.backend_api_env_file_arn
  db_env_file_arn = var.backend_db_env_file_arn
  # redis_env_file_arn = var.backend_redis_env_file_arn
  cluster_name = var.cluster_name
  cpu = var.api_cpu
  memory = var.api_memory
}
resource "aws_ecs_service" "backend_api" {
  name            = "backend-api"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = module.backend_api_task_definition.task_definition_arn
  desired_count   = var.desired_backend_api_instances_count
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight           = 1  # Set weight to control the allocation of this capacity provider
  }

  network_configuration {
    subnets          = data.aws_subnets.default_subnets.ids
    security_groups = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.backend_api_target_group_arn
    container_name = module.backend_api_task_definition.container_name
    container_port = 8080
  }

  tags = {
    Environment = terraform.workspace
    Project     = "${terraform.workspace} cluster"
  }
  depends_on = [module.backend_api_task_definition]
}

# backend cron
module "backend_cron_task_definition" {
  source = "./backend_cron_task_definition"
  repo_url = var.backend_cron_repo_url
  env_file_arn = var.backend_cron_env_file_arn
  db_env_file_arn = var.backend_db_env_file_arn
  # redis_env_file_arn = var.backend_redis_env_file_arn
  cluster_name = var.cluster_name
  cpu = var.cron_cpu
  memory = var.cron_memory
}

resource "aws_ecs_service" "backend_cron" {
  name            = "backend-cron"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = module.backend_cron_task_definition.task_definition_arn
  desired_count   = var.desired_backend_cron_instances_count
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight           = 1  # Set weight to control the allocation of this capacity provider
  }

  network_configuration {
    subnets          = data.aws_subnets.default_subnets.ids
    security_groups = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.backend_cron_target_group_arn
    container_name = module.backend_cron_task_definition.container_name
    container_port = 8080
  }

  tags = {
    Environment = terraform.workspace
    Project     = "${terraform.workspace} cluster"
  }
  depends_on = [module.backend_cron_task_definition]
}

# frontend
module "frontend_task_definition" {
  source = "./frontend_task_definition"
  repo_url = var.frontend_repo_url
  cluster_name = var.cluster_name
  cpu = var.frontend_cpu
  memory = var.frontend_memory
}
resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = module.frontend_task_definition.task_definition_arn
  desired_count   = var.desired_frontend_instances_count
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight           = 1  # Set weight to control the allocation of this capacity provider
  }

  network_configuration {
    subnets          = data.aws_subnets.default_subnets.ids
    security_groups = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name = module.frontend_task_definition.container_name
    container_port = 80
  }

  tags = {
    Environment = terraform.workspace
    Project     = "${terraform.workspace} cluster"
  }
  depends_on = [module.frontend_task_definition]
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/aws/ecs/${var.cluster_name}"
}
