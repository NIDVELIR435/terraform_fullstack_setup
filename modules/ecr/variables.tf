variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
  validation {
    condition     = can(regex("development|testing|production", var.repository_name))
    error_message = "Allowed values are development, testing or production"
  }
}

variable "image_count" {
  description = "The number of images to retain"
  type        = number
  default     = 5
}
