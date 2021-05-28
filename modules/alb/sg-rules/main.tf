resource "aws_security_group_rule" "alb_https_inbound" {
  type              = "ingress"
  description       = "https inbound"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
  security_group_id = var.lb_sg_id
}

resource "aws_security_group_rule" "alb_http_inbound" {
  type              = "ingress"
  description       = "http inbound for redirect to https"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
  security_group_id = var.lb_sg_id
}

resource "aws_security_group_rule" "alb_outbound" {
  type                     = "egress"
  description              = "http jenkins port"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = var.lb_sg_id
  source_security_group_id = var.target_sg_id
}

resource "aws_security_group_rule" "target_inbound" {
  type                     = "ingress"
  description              = "http inbound"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = var.target_sg_id
  source_security_group_id = var.lb_sg_id
}
