resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/todo-${var.env}"
  retention_in_days = 14
}


