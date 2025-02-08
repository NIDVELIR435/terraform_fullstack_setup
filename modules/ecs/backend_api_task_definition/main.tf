locals {
  task_definition_name = "${var.cluster_name}_backend_api"
  container_name = "backend"
}

# Create an IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.cluster_name}_backend_api_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = ""
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# Attach inline policy for S3 access
resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "${var.cluster_name}_backend_api_execution_policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3Access"
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = [var.env_file_arn, var.db_env_file_arn, /*var.redis_env_file_arn*/]
      },
      {
        Sid      = "CloudWatchLogsAccess",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${local.task_definition_name}:*"
      }
    ]
  })
}

# Attach the policy that allows pulling from ECR and writing to CloudWatch Logs
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}


resource "aws_ecs_task_definition" "backend" {
  family                   = local.task_definition_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"
  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn


  container_definitions = jsonencode([
    {
      name         = local.container_name
      image        = "${var.repo_url}:latest"
      portMappings = [
        {
          name = "backend-8080-tcp",
          containerPort = 8080,
          hostPort = 8080,
          protocol = "tcp"
        }
      ]
      cpu          = var.cpu
      memory       = var.memory
      essential    = true
      environmentFiles = [
        {
          value = var.env_file_arn
          type  = "s3"
        },
        {
          value = var.db_env_file_arn
          type  = "s3"
        },
        # {
        #   value = var.redis_env_file_arn
        #   type  = "s3"
        # }
      ]
      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -qO- http://localhost:8080/api/health || exit 1"
        ]
        interval = 120
        timeout = 3
        retries = 3
        startPeriod = 10
      }
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-group         = "/ecs/${local.task_definition_name}"
          awslogs-create-group  = "true"
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }
    }
  ])
}
