locals {
  secret_arns = concat(
    [for secret in var.secrets : secret.ValueFrom],
    [var.dockerhub_credentials_arn],
  var.kms_keys)
}

module "iam" {
  source      = "./modules/iam"
  secret_arns = local.secret_arns
}

module "ecs" {
  source                    = "./modules/ecs"
  dockerhub_credentials_arn = var.dockerhub_credentials_arn
  environment_variables     = var.environment_variables
  jenkins_agent_image       = var.jenkins_agent_image
  secrets                   = var.secrets
  task_role_arn             = module.iam.jenkins_agent_task_role_arn
  task_execution_role_arn   = module.iam.jenkins_agent_execution_role_arn
  vpc_id                    = var.vpc_id
}

resource "aws_iam_policy" "create_tasks" {
  name        = "jenkins_master_create_agent_tasks"
  description = "Access top create jenkins agent tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:ListClusters",
          "ecs:DescribeContainerInstances",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition"
        ]
        Effect   = "Allow"
        Resource = "*"
        }, {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = [module.iam.jenkins_agent_execution_role_arn, module.iam.jenkins_agent_task_role_arn]
      },
      {
        Action = [
          "ecs:ListContainerInstances",
          "ecs:DescribeClusters"
        ]
        Effect   = "Allow"
        Resource = module.ecs.jenkins_agent_cluster_arn
      },
      {
        Action = [
          "ecs:RunTask"
        ]
        Effect   = "Allow"
        Resource = module.ecs.jenkins_agent_task_definition_arn
        Condition = {
          "ArnEquals" = {
            "ecs:cluster" = [module.ecs.jenkins_agent_cluster_arn]
          }
        }
      },
      {
        Action = [
          "ecs:DescribeTasks",
          "ecs:StopTask"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecs:*:*:task/*"
        Condition = {
          "ArnEquals" = {
            "ecs:cluster" = [module.ecs.jenkins_agent_cluster_arn]
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.jenkins_master_account}:root"
      ]
    }
  }
}


resource "aws_iam_role" "this" {
  name               = var.assume_role_name
  path               = var.assume_role_path
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.create_tasks.arn
}


resource "aws_iam_role" "agent_task_creation_role" {
  name = "jenkins_agent_task_creation_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = { "AWS" : "arn:aws:iam::${var.jenkins_master_account}:root" }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "agent_task_creation_attachment" {
  role       = aws_iam_role.agent_task_creation_role.name
  policy_arn = aws_iam_policy.create_tasks.arn
}
