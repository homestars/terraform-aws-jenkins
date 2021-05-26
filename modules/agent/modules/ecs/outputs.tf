output "jenkins_agent_cluster_arn" {
  description = "The arn for the cluster"
  value       = aws_ecs_cluster.cluster.arn
}

output "jenkins_agent_task_definition_arn" {
  description = "The arn for the task definition"
  value       = aws_ecs_task_definition.agent_task.arn
}
