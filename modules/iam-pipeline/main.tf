resource "aws_iam_user" "user" {
  name = "${terraform.workspace}-pipeline-user"
}

resource "aws_iam_policy" "custom_ecr_ecs_policy" {
  name        = "${terraform.workspace}_ecr_ecs_custom_policy"
  description = "Custom policy to allow ECR actions and ECS service updates"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECRActions"
        Effect = "Allow"
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:DescribeImages"
        ]
        Resource = var.allowed_ecr_arn_list
      },
      {
        Sid    = "AllowECSServiceUpdate"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = var.allowed_ecs_arn_list
      },
      {
        Sid    = "AllowRDSSecurityGroupActions"
        Effect = "Allow"
        Action = [
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupIngress",
        ]
        Resource = var.rds_security_group_arn_list
      },
      {
        Sid    = ""
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      },
      {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": var.ecs_task_executions_arn_list
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ecs_task_execution_role_attachment" {
  user       = aws_iam_user.user.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.custom_ecr_ecs_policy.arn
}

# Create access keys for the IAM user
resource "aws_iam_access_key" "user_access_key" {
  user = aws_iam_user.user.name
}

locals {
  db_content = <<EOF
AWS_ACCESS_KEY_ID=${aws_iam_access_key.user_access_key.id}
AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.user_access_key.secret}
   EOF
}

resource "local_file" "env_file" {
  filename = "${path.module}/../../.${terraform.workspace}.pipeline-iam.env"
  content  = local.db_content
}
