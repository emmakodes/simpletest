resource "aws_ecs_cluster" "this" {
  name = "${var.project}-cluster"
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "web",
      image = "${aws_ecr_repository.backend.repository_url}:initial",
      essential = true,
      portMappings = [
        {
          containerPort = 8000,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = var.region,
          awslogs-group         = aws_cloudwatch_log_group.app.name,
          awslogs-stream-prefix = "web"
        }
      },
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/healthz || exit 1"],
        interval    = 10,
        timeout     = 5,
        retries     = 3,
        startPeriod = 10
      }
    }
  ])
}


