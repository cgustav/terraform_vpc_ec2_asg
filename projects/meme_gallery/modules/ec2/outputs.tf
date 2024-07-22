output "asg_names" {
  description = "Names of the created Auto Scaling Groups"
  value       = { for k, v in aws_autoscaling_group.server_asg : k => v.name }
}

output "launch_template_ids" {
  description = "IDs of the created launch templates"
  value       = { for k, v in aws_launch_template.server : k => v.id }
}
