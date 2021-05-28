data "github_ip_ranges" "gh_ranges" {}

locals {
  secret_arns = concat(
    [for secret in var.secrets : secret.ValueFrom],
    [var.dockerhub_credentials_arn],
  var.kms_keys)
}

module "efs" {
  source     = "./modules/efs"
  subnet_ids = var.private_subnet_ids
  vpc_id     = var.vpc_id
}

module "iam" {
  source                      = "./modules/iam"
  agent_creation_policies     = var.agent_creation_policies
  jenkins_jobs_iam_policy_arn = module.efs.jenkins_jobs_iam_policy_arn
  secret_arns                 = local.secret_arns
}

module "alb" {
  source = "./modules/alb"

  public_cidr_blocks  = concat(data.github_ip_ranges.gh_ranges.hooks, var.public_http_cidr_blocks)
  private_cidr_blocks = var.private_http_cidr_blocks

  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids
  vpc_id             = var.vpc_id

  tls_certificate_arn = var.tls_certificate_arn
}

locals {
  environment_variables = concat(
    var.environment_variables,
    [
      {
        name  = "JENKINS_URL"
        value = "https://${var.jenkins_url}"
      }
    ]
  )
}

resource "aws_security_group_rule" "instance_outbound" {
  type              = "egress"
  description       = "jenkins outbound"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb.target_sg_id
}

module "ecs" {
  source                    = "./modules/ecs"
  dockerhub_credentials_arn = var.dockerhub_credentials_arn
  environment_variables     = local.environment_variables
  file_system_id            = module.efs.jenkins_jobs_id
  jenkins_master_image      = var.jenkins_master_image
  jobs_access_point_id      = module.efs.jenkins_jobs_ap_id
  private_target_group_arn  = module.alb.private_target_group_arn
  public_target_group_arn   = module.alb.public_target_group_arn
  sg_ids                    = [module.alb.target_sg_id, module.efs.sg_id]
  secrets                   = var.secrets
  subnet_ids                = var.private_subnet_ids
  task_role_arn             = module.iam.jenkins_master_task_role_arn
  task_execution_role_arn   = module.iam.jenkins_master_execution_role_arn
  workspace_access_point_id = module.efs.jenkins_workspace_ap_id
  vpc_id                    = var.vpc_id
}
