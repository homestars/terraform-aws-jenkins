output "public_dns" {
  description = "The dns of the public lb for jenkins"
  value       = module.alb.public_dns
}

output "private_dns" {
  description = "The dns of the private lb for jenkins"
  value       = module.alb.private_dns
}
