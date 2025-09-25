variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "todo"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "desired_count" {
  description = "Desired task count for ECS services"
  type        = number
  default     = 0
}


