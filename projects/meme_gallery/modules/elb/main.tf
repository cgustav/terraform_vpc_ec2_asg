# ALB configuration for Pokemon Online Game AWS Infrastructure

# ALB resource
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "meme-gallery-alb"
  }
}

resource "aws_lb_target_group" "web_alb" {
  name     = "meme-gallery-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# Definir el Target Group
resource "aws_lb_target_group" "web_api" {
  name     = "pokemon-api-tg"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = "200-299" # Add this line to specify successful response codes
  }
}

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.web_alb.arn

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "web_https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.lb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_alb.arn
  }
}



# Opcional: Forward HTTPS traffic to 3001
resource "aws_lb_listener" "api_https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "3001"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.lb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_alb.arn
  }
}
