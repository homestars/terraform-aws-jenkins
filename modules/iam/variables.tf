variable "agent_creation_policies" {
  description = "Set of policies for spinning up agents in agent clusters"
  type        = set(string)
  default     = []
}

variable "jenkins_jobs_iam_policy_arn" {
  description = "The arn for the efs policy"
  type        = string
}

variable "secret_arns" {
  description = "A list of arns of secrets and keys to grant accesss to"
  type        = list(string)
  default     = []
}
