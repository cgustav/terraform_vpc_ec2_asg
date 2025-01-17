output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "web_security_group_id" {
  value = aws_security_group.web.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "internal_security_group_id" {
  value = aws_security_group.internal.id
}
