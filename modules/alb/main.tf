resource "aws_security_group" "this" {
  name_prefix = "${var.name}-alb-"
  description = "Security group for ${var.name} ALB"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each          = toset(var.ingress_cidr_blocks)
  security_group_id = aws_security_group.this.id
  description       = "Allow HTTP from ${each.value}"
  ip_protocol       = "tcp"
  from_port         = var.http_port
  to_port           = var.http_port
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each          = toset(var.ingress_cidr_blocks)
  security_group_id = aws_security_group.this.id
  description       = "Allow HTTPS from ${each.value}"
  ip_protocol       = "tcp"
  from_port         = var.https_port
  to_port           = var.https_port
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all egress"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout
  enable_http2               = var.enable_http2

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_lb_target_group" "this" {
  name                 = "${var.name}-tg"
  port                 = var.target_group_port
  protocol             = var.target_group_protocol
  target_type          = var.target_type
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    port                = var.health_check_port
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(var.tags, { Name = "${var.name}-tg" })
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(var.tags, { Name = "${var.name}-https" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = tostring(var.https_port)
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-http" })
}
