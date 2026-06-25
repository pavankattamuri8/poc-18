variable "vpc_id" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "db_endpoint" {}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  subnets = var.public_subnets
}

resource "aws_lb_target_group" "tg" {
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
}

resource "aws_ecs_task_definition" "task" {
  family = "app"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"

  cpu = "256"
  memory = "512"

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${var.image}"

      portMappings = [
        { containerPort = 80 }
      ]

      environment = [
        {
          name  = "DB_HOST"
          value = var.db_endpoint
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type = "FARGATE"
  desired_count = 2

  network_configuration {
    subnets = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name = "app"
    container_port = 80
  }
}

output "ecs_sg" { value = aws_security_group.ecs_sg.id }
output "alb_dns" { value = aws_lb.alb.dns_name }
