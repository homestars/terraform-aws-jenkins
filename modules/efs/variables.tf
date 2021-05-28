variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "The ids of the subnets Jenkins Master can exist in"
  type        = set(string)
}

variable "vpc_id" {
  description = "The id of the VPC Jenkins Master is created in"
  type        = string
}
