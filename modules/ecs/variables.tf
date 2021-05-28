variable "jobs_access_point_id" {
  description = "ID of jenkins jobs fs acceess point"
  type        = string
}

variable "workspace_access_point_id" {
  description = "ID of jenkins workspace fs acceess point"
  type        = string
}

variable "dockerhub_credentials_arn" {
  description = "ARN of dockerhub credentials username/password entry in AWS Secrets Manager"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for Jenkins Master"
  type        = list(map(string))
}

variable "file_system_id" {
  description = "ID of jenkins jobs fs"
  type        = string
}

variable "jenkins_master_image" {
  description = "Docker.io url for image"
  type        = string
}

variable "sg_ids" {
  description = "The ids of the security group for the jenkins master"
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

variable "subnet_ids" {
  description = "Subnet ids for the task to launch in"
  type        = set(string)
}

variable "private_target_group_arn" {
  description = "ARN of private lb target group"
  type        = string
}

variable "public_target_group_arn" {
  description = "ARN of public lb target group"
  type        = string
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
