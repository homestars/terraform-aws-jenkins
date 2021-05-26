resource "aws_security_group" "jenkins_master_efs_sg" {
  name        = "Jenkins Master EFS Access"
  description = "Allow NFS traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "http jenkins port"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    self        = true
  }
  egress {
    description = "http jenkins port"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    self        = true
  }
}

resource "aws_efs_file_system" "efs" {
  creation_token = "jenkins_master"
  encrypted      = true
  tags = merge({
    "Name" = "jenkins_master"
    },
    var.tags
  )
}

resource "aws_efs_access_point" "jobs" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/jenkins_home/jobs"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }
  tags = merge({
    "Name" = "jenkins_master_jobs"
    },
    var.tags
  )
}

resource "aws_efs_access_point" "workspace" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/jenkins_home/workspace"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }
  tags = merge({
    "Name" = "jenkins_master_workspace"
    },
    var.tags
  )
}

resource "aws_iam_policy" "policy" {
  name        = "jenkins_efs_access"
  description = "Access to EFS volume for jenkins_master persistence"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Effect   = "Allow"
        Resource = aws_efs_file_system.efs.arn
        "Condition" = {
          "StringEquals" = { "elasticfilesystem:AccessPointArn" : aws_efs_access_point.jobs.arn }
        }
      },
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Effect   = "Allow"
        Resource = aws_efs_file_system.efs.arn
        "Condition" = {
          "StringEquals" = { "elasticfilesystem:AccessPointArn" : aws_efs_access_point.workspace.arn }
        }
      }
    ]
  })
}

resource "aws_efs_mount_target" "mount_targets" {
  for_each = var.subnet_ids

  file_system_id  = aws_efs_file_system.efs.id
  security_groups = [aws_security_group.jenkins_master_efs_sg.id]
  subnet_id       = each.value
}
