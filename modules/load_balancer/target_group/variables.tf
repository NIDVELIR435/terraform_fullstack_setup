variable "target_group_name" {
  description = "The name of target group name"
  type        = string
  validation {
    condition     = can(regex("backend|frontend", var.target_group_name))
    error_message = "Allowed values are backend or frontend"
  }
}

variable "health_path" {
  description = "The path for health check route"
  type        = string
}
variable "port" {
  type        = number
}
