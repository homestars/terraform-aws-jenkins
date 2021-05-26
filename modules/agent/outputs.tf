output "agent_task_creation_policy_arn" {
  description = "The arn for the task creation policy"
  value       = aws_iam_policy.create_tasks.arn
}

output "agent_task_creation_role_arn" {
  description = "The name for the task creation role for cross account assumption"
  value       = aws_iam_role.agent_task_creation_role.name
}

output "cluster_arn" {
  description = "The arn for the agent cluster"
  value       = module.ecs.jenkins_agent_cluster_arn
}

output "task_definition_arn" {
  description = "The arn for the task definition"
  value       = module.ecs.jenkins_agent_task_definition_arn
}

output "execution_role_arn" {
  description = "The arn of the execution role for the agent"
  value       = module.iam.jenkins_agent_execution_role_arn

}
