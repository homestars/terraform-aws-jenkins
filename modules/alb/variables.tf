variable "public_cidr_blocks" {
  description = "List of cidr blocks to allow inbound access on 443, in addition to github."
  type        = list(string)
}

variable "private_cidr_blocks" {
  description = "List of cidr blocks to allow inbound access on 443, in addition to github."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnet ids for the load balancer to expose itself in"
  type        = set(string)
}

variable "public_subnet_ids" {
  description = "Subnet ids for the load balancer to expose itself in"
  type        = set(string)
}

variable "tls_certificate_arn" {
  description = "tls certificate arn from certificate manager"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}
