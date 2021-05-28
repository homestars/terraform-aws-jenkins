variable "agent_creation_policies" {
  description = "Set of policies for spinning up agents in agent clusters"
  type        = set(string)
  default     = []
}

variable "dockerhub_credentials_arn" {
  description = "ARN of dockerhub credentials username/password entry in AWS Secrets Manager"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for Jenkins Master"
  type        = list(map(string))
}

variable "jenkins_master_image" {
  description = "Docker.io url for image"
  type        = string
}

variable "jenkins_url" {
  description = "Jenkins URL (DNS managed outside of module)"
  type        = string
}

variable "kms_keys" {
  description = "A list of kms keys used to encrypt dockerhub_credentials_arn and the entries in secrets."
  type        = list(string)
}

variable "private_http_cidr_blocks" {
  description = "List of cidr blocks to allow inbound access over http(s)"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "The ids of the subnets jenkins_master cluster should exist on"
  type        = set(string)
}

variable "public_http_cidr_blocks" {
  description = "List of cidr blocks to allow inbound access http(s) (in addition to github hooks)"
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "Subnet ids for the load balancer to expose itself in"
  type        = set(string)
}

variable "secrets" {
  description = "A list of aws secret entries (dict with keys Name and ValueFrom being name and ARN respectively)."
  type = list(object({
    Name      = string
    ValueFrom = string
  }))
  default = []
}

variable "tls_certificate_arn" {
  description = "ARN for tls certificate in AWS Certificate Manager"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
}
