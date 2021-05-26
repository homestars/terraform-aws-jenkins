resource "aws_iam_policy" "policy" {
  name        = "jenkins_master_secret_access"
  description = "Access to secrets for jenkins_master"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters",
          "kms:Decrypt"
        ]
        Effect   = "Allow"
        Resource = var.secret_arns
      }
    ]
  })
}

resource "aws_iam_role" "execution_role" {
  name = "jenkins_master_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach-secrets" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "attach-registryRO" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "attach-ECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_role" {
  name = "jenkins_master_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_create_agents" {
  for_each   = var.agent_creation_policies
  role       = aws_iam_role.task_role.name
  policy_arn = each.key
}

resource "aws_iam_role_policy_attachment" "attach_efs" {
  role       = aws_iam_role.task_role.name
  policy_arn = var.jenkins_jobs_iam_policy_arn
}

