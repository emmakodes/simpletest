variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "env" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "enable_msk" {
  description = "Whether to create MSK cluster (Kafka). Can be costly."
  type        = bool
  default     = false
}


