variable "dockerhub_credentials_arn" {
  description = "ARN of dockerhub credentials username/password entry in AWS Secrets Manager"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for Jenkins Master"
  type        = list(map(string))
}

variable "jenkins_agent_image" {
  description = "Docker.io url for image"
  type        = string
}

variable "secrets" {
  description = "A list of aws secret entries (dict with keys Name and ValueFrom being name and ARN respectively)."
  type = list(object({
    Name      = string
    ValueFrom = string
  }))
  default = []
}

variable "task_role_arn" {
  description = "ARN of the role for the task"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ARN of the role for the task execution"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
}
