output "jenkins_jobs_id" {
  description = "The id of the filesystem"
  value       = aws_efs_file_system.efs.id
}

output "jenkins_jobs_ap_id" {
  description = "The id of the jobs access point"
  value       = aws_efs_access_point.jobs.id
}

output "jenkins_workspace_ap_id" {
  description = "The id of the workspace access point"
  value       = aws_efs_access_point.workspace.id
}

output "jenkins_jobs_iam_policy_arn" {
  description = "The arn of the iam_policy"
  value       = aws_iam_policy.policy.arn
}

output "sg_id" {
  description = "The id of the security group for the efs"
  value       = aws_security_group.jenkins_master_efs_sg.id
}
