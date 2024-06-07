terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>2.70.0"
    }
  }
  backend "s3" {
    bucket = "nebo-cicd-s3"
    key    = "tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"

}
resource "aws_default_vpc" "vpc" {
  tags = {
    Name = "vpc"
  }
}
resource "aws_default_subnet" "def_subnet_a" {
  availability_zone = "us-east-1a"
  tags = {
    Name = "def_subnet_a"
  }
}

resource "aws_default_subnet" "def_subnet_b" {
  availability_zone = "us-east-1b"
  tags = {
    Name = "def_subnet_b"
  }
}
resource "aws_default_subnet" "def_subnet_c" {
  availability_zone = "us-east-1c"
  tags = {
    Name = "def_subnet_c"
  }
}
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_default_vpc.vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ecs-sg"

  }
}
resource "aws_lb" "nebocicd_lb" {
  name               = "nebocicd-load-balancer"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_default_subnet.def_subnet_a.id, aws_default_subnet.def_subnet_b.id, aws_default_subnet.def_subnet_c.id]
}

resource "aws_security_group" "lb_sg" {
  name   = "load-balancer-security group"
  vpc_id = aws_default_vpc.vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_lb_target_group" "lb_target_group" {
  name        = "lb-target-group"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/status"
    unhealthy_threshold = "2"
  }
  depends_on = [aws_lb.nebocicd_lb]
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.nebocicd_lb.arn
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}
//aws sg for instnances
resource "aws_security_group" "ec2-sg" {
  name        = "allow-all-ec2"
  description = "allow all"
  vpc_id      = aws_default_vpc.vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "felipe"
  }
}

resource "aws_ecs_cluster" "nebocicd_cluster" {
  name = var.nebocicd_cluster
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "nebocicd_task" {
  family                   = "nebocicd-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions = jsonencode([
    {
      "name" : "nebocicd_container",
      "image" : "590183940136.dkr.ecr.us-east-1.amazonaws.com/nebo_cicd:latest",
      "memory" : 512,
      "cpu" : 256,
      "essential" : true,

      "portMappings" : [
        {
          "containerPort" : 9090,
          "hostPort" : 9090,
          "protocol" : "tcp"
        }
      ],


    }
  ])
  depends_on = [aws_iam_role_policy_attachment.ecs_execution_role_policy]
}
resource "aws_ecs_service" "nebocicd_ecs_service" {
  name                 = "nebocicd-ecs-service"
  cluster              = aws_ecs_cluster.nebocicd_cluster.id
  task_definition      = aws_ecs_task_definition.nebocicd_task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  force_new_deployment = true
  desired_count        = 2
  depends_on           = [aws_lb_listener.ecs_listener]
  network_configuration {
    subnets          = [aws_default_subnet.def_subnet_a.id, aws_default_subnet.def_subnet_b.id, aws_default_subnet.def_subnet_c.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id, aws_security_group.lb_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "nebocicd_container"
    container_port   = 9090
  }
  lifecycle {
    ignore_changes = [desired_count]
  }


}
output "lb_url" {
  value = aws_lb.nebocicd_lb.dns_name
}
output "cluster_name" {
  value = var.nebocicd_cluster
}

output "family_name" {
  value = aws_ecs_task_definition.nebocicd_task.family
}