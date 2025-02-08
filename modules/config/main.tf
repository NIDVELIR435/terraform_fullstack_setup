data "local_file" "workspace_config" {
  filename = "${path.module}/../../workspace-configs/${terraform.workspace}.tfvars.json"
}

locals {
  parsed_configs_from_file = jsondecode(data.local_file.workspace_config.content)

  s3_env = {
    env_bucket_name                     = "${terraform.workspace}-env-files"
    ecs_backend_api_main_env_file_path  = "ecs/backend/.api.env"
    ecs_backend_cron_main_env_file_path = "ecs/backend/.cron.env"
    ecs_backend_database_env_file_path  = "ecs/backend/.db.env"
    # ecs_backend_redis_env_file_path = "ecs/backend/.redis.env"

    assets_bucket_name   = "${terraform.workspace}-assets-files"
    logo_asset_file_path = "logo.png"
  }
}
