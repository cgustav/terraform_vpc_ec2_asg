# ALB configuration for Pokemon Online Game AWS Infrastructure

# ALB resource
resource "aws_lb" "pokemon_game" {
  name               = "pokemon-game-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "pokemon-game-alb"
  }
}

resource "aws_lb_target_group" "pokemon_game" {
  name     = "pokemon-game-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.pokemon_game.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.pokemon_game.arn

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = aws_lb.pokemon_game.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.lb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pokemon_game.arn
  }
}

# COMMENT THIS IF YOU DONT WANNA SETUP SSL CERTIFICATE VIA ACM
# resource "aws_lb_listener_certificate" "example" {
#   listener_arn    = aws_lb_listener.front_end.arn
#   certificate_arn = var.lb_certificate_arn
# }
