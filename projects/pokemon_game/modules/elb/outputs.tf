output "load_balancer_dns_name" {
  value = aws_lb.pokemon_game.dns_name
}

output "load_balancer_zone_id" {
  value = aws_lb.pokemon_game.zone_id
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.pokemon_game.arn
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.pokemon_api.arn
}



# load_balancer_dns
