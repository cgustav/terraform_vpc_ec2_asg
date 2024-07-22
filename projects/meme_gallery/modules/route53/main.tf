# Route 53 configuration for Pokemon Online Game AWS Infrastructure

resource "aws_route53_zone" "primary" {
  count = var.create_zone ? 1 : 0
  name  = var.domain_name
}

data "aws_route53_zone" "selected" {
  count = var.create_zone ? 0 : 1
  name  = var.domain_name
}

resource "aws_route53_record" "www" {
  zone_id = var.create_zone ? aws_route53_zone.primary[0].zone_id : data.aws_route53_zone.selected[0].zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
