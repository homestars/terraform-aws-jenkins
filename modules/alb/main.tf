locals {
  security_policy = "ELBSecurityPolicy-FS-1-2-2019-08"
}

### Security Groups ###
resource "aws_security_group" "target" {
  name        = "Jenkins Master target SG"
  description = "Allow traffic from LB"
  vpc_id      = var.vpc_id
  tags = {
    Name = "Jenkins Master target SG"
  }
}

resource "aws_security_group" "public" {
  name        = "Jenkins Master Public LB SG"
  description = "Allow https and jenkins agent inbound traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "Jenkins Master LB SG"
  }
}

resource "aws_security_group" "private" {
  name        = "Jenkins Master Private LB SG"
  description = "Allow https and jenkins agent inbound traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "Jenkins Master LB SG"
  }
}

### Security Group Rules ###
module "public_lb_sg_rules" {
  source       = "./sg-rules"
  cidr_blocks  = var.public_cidr_blocks
  lb_sg_id     = aws_security_group.public.id
  target_sg_id = aws_security_group.target.id
}

module "private_lb_sg_rules" {
  source       = "./sg-rules"
  cidr_blocks  = var.private_cidr_blocks
  lb_sg_id     = aws_security_group.private.id
  target_sg_id = aws_security_group.target.id
}

### Create the LBs ###
module "public_lb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name    = "jenkins-master-public-lb"
  subnets = var.public_subnet_ids
  vpc_id  = var.vpc_id

  enable_cross_zone_load_balancing = true
  idle_timeout                     = 30
  listener_ssl_policy_default      = local.security_policy
  load_balancer_type               = "application"

  security_groups = [aws_security_group.public.id]

  target_groups = [
    {
      name_prefix      = "jenkin"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"
      health_check = {
        matcher = "200-499"
        path    = "/"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.tls_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}

module "private_lb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  internal = true
  name     = "jenkins-master-private-lb"
  subnets  = var.private_subnet_ids
  vpc_id   = var.vpc_id

  enable_cross_zone_load_balancing = true
  idle_timeout                     = 30
  load_balancer_type               = "application"
  listener_ssl_policy_default      = local.security_policy

  security_groups = [aws_security_group.private.id]

  target_groups = [
    {
      name_prefix      = "jenkin"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"
      health_check = {
        matcher = "200-499"
        path    = "/"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.tls_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}
