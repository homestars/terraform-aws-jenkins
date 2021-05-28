output "jenkins_master_task_role_arn" {
  description = "The arn of the iam_role"
  value       = aws_iam_role.task_role.arn
}

output "jenkins_master_execution_role_arn" {
  description = "The arn of the iam_role"
  value       = aws_iam_role.execution_role.arn
}
