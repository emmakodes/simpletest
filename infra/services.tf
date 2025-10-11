# Placeholders: In Phase 6 we will wire Task Definitions and Services to ECR images built by CI/CD
# Here we expose the target group ARN for later listener rules

output "backend_target_group_arn" {
  value = aws_lb_target_group.backend.arn
}


