resource "aws_security_group" "msk" {
  count  = var.enable_msk ? 1 : 0
  name   = "todo-${var.env}-msk-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 9092
    to_port         = 9096
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_msk_cluster" "this" {
  count                = var.enable_msk ? 1 : 0
  cluster_name         = "todo-${var.env}-msk"
  kafka_version        = "3.6.0"
  number_of_broker_nodes = 2
  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    client_subnets  = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.msk[0].id]
  }
}


