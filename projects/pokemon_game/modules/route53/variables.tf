variable "domain_name" {
  description = "The domain name for the Route 53 zone"
  type        = string
}

variable "subdomain" {
  description = "The subdomain to create the record for"
  type        = string
  default     = "www"
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "The zone ID of the ALB"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new Route 53 zone or use an existing one"
  type        = bool
  default     = false
}
