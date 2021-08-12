variable "assume_role_name" {
  description = "Name of role to create for master to use"
  type        = string
  default     = "jenkins-agent-creator"
}

variable "assume_role_path" {
  description = "Path of role to create for master to use"
  type        = string
  default     = "/"
}

variable "dockerhub_credentials_arn" {
  description = "ARN of dockerhub credentials username/password entry in AWS Secrets Manager"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for Jenkins Master"
  type        = list(map(string))
  default     = []
}

variable "jenkins_agent_image" {
  description = "Docker.io url for image"
  type        = string
}

variable "jenkins_master_account" {
  description = "The account number of the master account"
  type        = string
}

variable "kms_keys" {
  description = "A list of kms keys used to encrypt dockerhub_credentials_arn and the entries in secrets."
  type        = list(string)
}

variable "secrets" {
  description = "A list of aws secret entries (dict with keys Name and ValueFrom being name and ARN respectively)."
  type = list(object({
    Name      = string
    ValueFrom = string
  }))
  default = []
}

variable "vpc_id" {
  description = "The id of the VPC"
}
