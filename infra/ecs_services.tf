locals {
  backend_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/todo-backend:latest"
  frontend_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/todo-frontend:latest"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "task_role" {
  name               = "todo-${var.env}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "todo-${var.env}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = local.backend_image
      essential = true
      portMappings = [{ containerPort = 8000, hostPort = 8000, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "backend"
        }
      }
      environment = [
        { name = "DATABASE_URL", value = "postgresql://app:app-password-change@${aws_db_instance.postgres.address}:5432/todo" },
        { name = "REDIS_URL", value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379/0" },
        { name = "JWT_SECRET", value = "change-me" },
        { name = "KAFKA_BROKER", value = "unused-for-now" },
        { name = "KAFKA_TOPIC", value = "todo-events" }
      ]
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name            = "todo-backend-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8000
  }
}

resource "aws_lb_listener_rule" "backend_forward" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    path_pattern { values = ["/ping", "/api/*", "/docs*", "/openapi.json"] }
  }
}

# Frontend Fargate service (Next.js dev server for simplicity)
resource "aws_ecs_task_definition" "frontend" {
  family                   = "todo-${var.env}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = local.frontend_image
      essential = true
      portMappings = [{ containerPort = 3000, hostPort = 3000, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "frontend"
        }
      }
      environment = []
      command = ["npm","run","start"]
      workingDirectory = "/app"
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "todo-frontend-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 3000
  }
}


