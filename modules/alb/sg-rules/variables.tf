variable "cidr_blocks" {
  description = "List of cidr blocks to allow inbound access to lb."
  type        = list(string)
}

variable "lb_sg_id" {
  description = "Security group of lb."
  type        = string
}

variable "target_sg_id" {
  description = "Security group of target."
  type        = string
}
