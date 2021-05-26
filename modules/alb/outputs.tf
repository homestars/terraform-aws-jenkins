output "arn" {
  description = "The arn of the LB"
  value       = module.public_lb.this_lb_arn
}

output "private_dns" {
  description = "The dns of the private alb"
  value       = module.private_lb.this_lb_dns_name
}

output "public_dns" {
  description = "The dns of the public alb"
  value       = module.public_lb.this_lb_dns_name
}

output "private_target_group_arn" {
  description = "The arn of the target group"
  value       = module.private_lb.target_group_arns[0]
}

output "public_target_group_arn" {
  description = "The arn of the target group"
  value       = module.public_lb.target_group_arns[0]
}

output "target_sg_id" {
  description = "The id of the security group for the LB"
  value       = aws_security_group.target.id
}
