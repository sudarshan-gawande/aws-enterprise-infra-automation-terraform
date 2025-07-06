# Application Load Balancer Module
# Maintained by: Sudarshan Gawande
# Portfolio     : https://sudarshangawande.com
# GitHub        : https://github.com/sudarshan-gawande
# LinkedIn      : https://www.linkedin.com/in/sudarshangawande

resource "aws_security_group" "lb_sg" {
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}

resource "aws_lb" "app_lb" {
  name               = "dev-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnet_ids

  tags = {
    Name        = "dev-app-lb"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}
