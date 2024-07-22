output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "rds_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.name
}

output "web_subnet_group_name" {
  value = aws_db_subnet_group.web_subnet_group.name
}
