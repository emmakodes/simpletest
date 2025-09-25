resource "aws_ecs_service" "staging" {
  name            = "${var.project}-staging"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [aws_security_group.service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.staging.arn
    container_name   = "web"
    container_port   = 8000
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_service" "prod" {
  name            = "${var.project}-prod"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [aws_security_group.service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prod.arn
    container_name   = "web"
    container_port   = 8000
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "staging_alb_dns" {
  value = aws_lb.staging.dns_name
}

output "prod_alb_dns" {
  value = aws_lb.prod.dns_name
}


