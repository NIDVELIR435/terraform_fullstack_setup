terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68.0"
    }
  }
  backend "s3" {
    bucket  = "devops-tf-state"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # configure your aws profile alias or different auth
    profile = "example"
  }
}

module "config" {
  source = "./modules/config"
}

module "ecr_backend_api" {
  source          = "./modules/ecr"
  repository_name = "${terraform.workspace}_backend_api"
  image_count     = module.config.ecr.backend_api_max_images_count
}

module "ecr_backend_cron" {
  source          = "./modules/ecr"
  repository_name = "${terraform.workspace}_backend_cron"
  image_count     = module.config.ecr.backend_cron_max_images_count
}

module "ecr_frontend" {
  source          = "./modules/ecr"
  repository_name = "${terraform.workspace}_frontend"
  image_count     = module.config.ecr.frontend_max_images_count
}



module "domain" {
  source = "./modules/domain"
  domain_name = module.config.domain.name
}

module "s3_api_env" {
  source                           = "./modules/s3_env"
  bucket_name                      = module.config.s3_env.env_bucket_name
  backend_file_path                = module.config.s3_env.ecs_backend_api_main_env_file_path
  backend_initial_source_file_path = "./assets/.sample.env"
}
module "s3_cron_env" {
  source                           = "./modules/s3_env"
  bucket_name                      = module.config.s3_env.env_bucket_name
  backend_file_path                = module.config.s3_env.ecs_backend_cron_main_env_file_path
  backend_initial_source_file_path = "./assets/.sample.env"
}
module "s3_assets" {
  source                           = "./modules/s3_assets"
  bucket_name                      = module.config.s3_env.assets_bucket_name
  backend_file_path                = module.config.s3_env.logo_asset_file_path
  backend_initial_source_file_path = "./assets/s3/logo.png"
}

module "mysql" {
  source = "./modules/mysql"
  max_connections = module.config.mysql.max_connections
  instance_class = module.config.mysql.instance_class
}

module "write_mysql_file" {
  source                             = "./modules/write_mysql_file"
  host                               = module.mysql.host
  port                               = module.mysql.port
  username                           = module.mysql.username
  password                           = module.mysql.password
  database                           = module.mysql.database
  bucket_name                        = module.config.s3_env.env_bucket_name
  ecs_backend_database_env_file_path = module.config.s3_env.ecs_backend_database_env_file_path
}

# module "redis" {
#   source = "./modules/redis"
# }

# module "write_redis_file" {
#   source = "./modules/write_redis_file"
#   host = module.redis.host
#   port = module.redis.port
#   bucket_name = module.config.s3_env.env_bucket_name
#   ecs_backend_redis_env_file_path = module.config.s3_env.ecs_backend_redis_env_file_path
# }

module "load_balancer" {
  source          = "./modules/load_balancer"
  certificate_arn = module.domain.certificate_arn
  domain_zone_id  = module.domain.zone_id
  domain_with_sub = module.domain.domain_with_sub
}

module "ecs" {
  source                    = "./modules/ecs"
  cluster_name              = "${terraform.workspace}_cluster"
  backend_api_repo_url      = module.ecr_backend_api.repo_url
  backend_cron_repo_url     = module.ecr_backend_cron.repo_url
  frontend_repo_url         = module.ecr_frontend.repo_url
  backend_api_env_file_arn  = "arn:aws:s3:::${module.config.s3_env.env_bucket_name}/${module.config.s3_env.ecs_backend_api_main_env_file_path}"
  backend_cron_env_file_arn = "arn:aws:s3:::${module.config.s3_env.env_bucket_name}/${module.config.s3_env.ecs_backend_cron_main_env_file_path}"
  backend_db_env_file_arn   = "arn:aws:s3:::${module.config.s3_env.env_bucket_name}/${module.config.s3_env.ecs_backend_database_env_file_path}"
  # backend_redis_env_file_arn       = "arn:aws:s3:::${module.config.s3_env.env_bucket_name}/${module.config.s3_env.ecs_backend_redis_env_file_path}"
  backend_api_target_group_arn         = module.load_balancer.backend_api_target_group_arn
  backend_cron_target_group_arn        = module.load_balancer.backend_cron_target_group_arn
  frontend_target_group_arn            = module.load_balancer.frontend_target_group_arn
  desired_backend_api_instances_count  = module.config.ecs.desired_api_instances_count
  desired_backend_cron_instances_count = module.config.ecs.desired_cron_instances_count
  desired_frontend_instances_count     = module.config.ecs.desired_frontend_instances_count
  api_cpu                              = module.config.ecs.ecs_api_cpu
  api_memory                           = module.config.ecs.ecs_api_memory
  cron_cpu                             = module.config.ecs.ecs_cron_cpu
  cron_memory                          = module.config.ecs.ecs_cron_memory
  frontend_cpu                         = module.config.ecs.ecs_frontend_cpu
  frontend_memory                      = module.config.ecs.ecs_frontend_memory
  depends_on = [
    module.ecr_backend_api,
    module.ecr_backend_cron,
    module.ecr_frontend,
    module.s3_api_env,
    module.s3_cron_env,
    module.mysql,
    # module.redis,
  ]
}

module "pipeline-iam" {
  source                       = "./modules/iam-pipeline"
  allowed_ecr_arn_list         = [module.ecr_backend_cron.repo_arn, module.ecr_backend_api.repo_arn, module.ecr_frontend.repo_arn]
  allowed_ecs_arn_list         = [module.ecs.backend_api_service_arn, module.ecs.backend_cron_service_arn, module.ecs.frontend_service_arn]
  rds_security_group_arn_list  = [module.mysql.pipeline_security_group_arn]
  ecs_task_executions_arn_list = [module.ecs.backend_api_task_execution_role_arn, module.ecs.backend_cron_task_execution_role_arn, module.ecs.frontend_task_execution_role_arn]
  depends_on = [
    module.ecs
  ]
}
