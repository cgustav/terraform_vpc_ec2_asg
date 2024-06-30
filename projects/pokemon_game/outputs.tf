# Output values for Pokemon Online Game AWS Infrastructure

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.alb.load_balancer_dns
}

output "database_endpoint" {
  description = "Endpoint of the RDS database"
  value       = module.rds.database_endpoint
}