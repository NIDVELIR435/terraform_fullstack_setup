
resource "aws_ecr_repository" "repo" {
  name = var.repository_name
}

resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
      {
          "rules": [
              {
                  "rulePriority": 1,
                  "description": "Keep only the last ${var.image_count} images",
                  "selection": {
                      "tagStatus": "untagged",
                      "countType": "imageCountMoreThan",
                      "countNumber": ${var.image_count}
                  },
                  "action": {
                      "type": "expire"
                  }
              }
          ]
      }
  EOF
}
