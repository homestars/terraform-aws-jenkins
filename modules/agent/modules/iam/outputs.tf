output "jenkins_agent_task_role_arn" {
  description = "The arn of the iam_role for the agent task"
  value       = aws_iam_role.task_role.arn
}

output "jenkins_agent_execution_role_arn" {
  description = "The arn of the iam_role for launching the task"
  value       = aws_iam_role.execution_role.arn
}
