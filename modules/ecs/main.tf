resource "aws_ecs_cluster" "cluster" {
  name = "jenkins_master"
}

locals {
  log_group_name = "jenkins-master"
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = local.log_group_name
      awslogs-region        = "us-east-1"
      awslogs-stream-prefix = "jenkins-master-"
    }
  }
}

resource "aws_cloudwatch_log_group" "jenkins_master" {
  name = local.log_group_name
}

resource "aws_ecs_task_definition" "master_task" {
  family                   = "jenkins_master"
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  volume {
    name = "secrets"
  }
  volume {
    name = "jenkins_jobs"
    efs_volume_configuration {
      file_system_id          = var.file_system_id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 20049
      authorization_config {
        access_point_id = var.jobs_access_point_id
        iam             = "ENABLED"
      }
    }
  }
  volume {
    name = "jenkins_workspace"
    efs_volume_configuration {
      file_system_id          = var.file_system_id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 20449
      authorization_config {
        access_point_id = var.workspace_access_point_id
        iam             = "ENABLED"
      }
    }
  }
  container_definitions = jsonencode([
    {
      name  = "jenkins_master"
      image = var.jenkins_master_image
      repositoryCredentials = {
        credentialsParameter = var.dockerhub_credentials_arn
      }
      essential         = true
      cpu               = 2048
      memoryReservation = 4096
      logConfiguration  = local.log_configuration
      environment       = var.environment_variables
      secrets           = var.secrets
      mountPoints = [
        {
          ContainerPath = "/run/secrets/"
          ReadOnly      = true
          SourceVolume  = "secrets"
        },
        {
          ContainerPath = "/var/jenkins_home/jobs"
          SourceVolume  = "jenkins_jobs"
        },
        {
          ContainerPath = "/var/jenkins_home/workspace"
          SourceVolume  = "jenkins_workspace"
        }
      ]
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        },
        {
          containerPort = 50000
          hostPort      = 50000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "jenkins_master" {
  cluster                           = aws_ecs_cluster.cluster.id
  desired_count                     = 1
  health_check_grace_period_seconds = 240
  launch_type                       = "FARGATE"
  name                              = "jenkins_master"
  platform_version                  = "1.4.0"
  task_definition                   = aws_ecs_task_definition.master_task.arn

  network_configuration {
    assign_public_ip = false
    subnets          = var.subnet_ids
    security_groups  = var.sg_ids
  }

  load_balancer {
    target_group_arn = var.private_target_group_arn
    container_name   = "jenkins_master"
    container_port   = 8080
  }

  load_balancer {
    target_group_arn = var.public_target_group_arn
    container_name   = "jenkins_master"
    container_port   = 8080
  }

}
