output "load_balancer_dns_name" {
  value = aws_lb.web_alb.dns_name
}

output "load_balancer_zone_id" {
  value = aws_lb.web_alb.zone_id
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.web_alb.arn
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.web_api.arn
}
