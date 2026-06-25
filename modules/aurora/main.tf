variable "vpc_id" {}
variable "private_subnets" {}
variable "ecs_sg" {}

resource "aws_db_subnet_group" "db" {
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [var.ecs_sg]
  }
}

resource "aws_rds_cluster" "aurora" {
  engine = "aurora-mysql"
  master_username = "admin"
  master_password = "Pavan@12345"

  db_subnet_group_name = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  database_name = "mydb"
}

resource "aws_rds_cluster_instance" "db" {
  count = 2
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class = "db.t3.medium"
  engine = "aurora-mysql"
}

output "endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}
