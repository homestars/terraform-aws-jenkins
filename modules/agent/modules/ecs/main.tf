resource "aws_ecs_cluster" "cluster" {
  name = "jenkins_agent"
}

locals {
  log_group_name = "jenkins-agent"
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = local.log_group_name
      awslogs-region        = "us-east-1"
      awslogs-stream-prefix = "jenkins-agent-"
    }
  }
}

resource "aws_cloudwatch_log_group" "jenkins_agent" {
  name = local.log_group_name
}

resource "aws_ecs_task_definition" "agent_task" {
  family                   = "jenkins_agent"
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  volume {
    name = "secrets"
  }
  container_definitions = jsonencode([
    {
      name  = "jenkins_agent"
      image = var.jenkins_agent_image
      repositoryCredentials = {
        credentialsParameter = var.dockerhub_credentials_arn
      }
      essential        = true
      logConfiguration = local.log_configuration
      environment      = var.environment_variables
      secrets          = var.secrets
      mountPoints = [
        {
          ContainerPath = "/run/secrets/"
          ReadOnly      = true
          SourceVolume  = "secrets"
        }
      ]
    }
  ])
}
