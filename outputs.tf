output "private_dns" {
  description = "The dns of the private lb for jenkins"
  value       = module.alb.private_dns
}

output "private_sg_id" {
  description = "The id of the security group for the private LB"
  value       = module.alb.private_sg_id
}

output "public_dns" {
  description = "The dns of the public lb for jenkins"
  value       = module.alb.public_dns
}

output "public_sg_id" {
  description = "The id of the security group for the public LB"
  value       = module.alb.public_sg_id
}

output "target_sg_id" {
  description = "The id of the security group for the ECS instances"
  value       = module.alb.target.id
}
