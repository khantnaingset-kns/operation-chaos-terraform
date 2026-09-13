data "aws_partition" "this" {}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-ec2-"
  description = "Security group for ${var.name} EC2 instances"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, { Name = "${var.name}-ec2-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id            = aws_security_group.this.id
  description                  = "Allow application traffic from the ALB"
  ip_protocol                  = "tcp"
  from_port                    = var.target_group_port
  to_port                      = var.target_group_port
  referenced_security_group_id = var.alb_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all egress"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_iam_role" "this" {
  name = "${var.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.name}-ec2-role" })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-ec2-profile"
  role = aws_iam_role.this.name

  tags = merge(var.tags, { Name = "${var.name}-ec2-profile" })
}

resource "aws_launch_template" "this" {
  name          = "${var.name}-lt"
  description   = "Launch template for ${var.name}"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = var.user_data == null ? null : base64encode(var.user_data)

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  vpc_security_group_ids = [aws_security_group.this.id]

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, { Name = "${var.name}-instance" })
  }

  tags = merge(var.tags, { Name = "${var.name}-lt" })

  depends_on = [
    aws_iam_role_policy_attachment.this,
    aws_vpc_security_group_ingress_rule.this,
    aws_vpc_security_group_egress_rule.this,
  ]
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 100
      max_healthy_percentage = 200
      skip_matching          = true
    }
  }

  dynamic "tag" {
    for_each = merge(var.tags, { Name = "${var.name}-asg" })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "this" {
  name                   = "${var.name}-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    disable_scale_in = var.disable_scale_in

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.cpu_target_value
  }

  estimated_instance_warmup = var.instance_warmup
}
