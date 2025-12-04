provider "aws" {
  region = var.region
}

# ------------------------------
# IAM Role & Profile
# ------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "autoscale-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "autoscale-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ------------------------------
# Launch Template
# ------------------------------
resource "aws_launch_template" "template" {
  name_prefix   = "static-site-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    security_groups = [var.security_group_id]
  }

  user_data = base64encode(file("userdata.sh"))
}

# ------------------------------
# Application Load Balancer
# ------------------------------
resource "aws_lb" "alb" {
  name               = "static-alb"
  load_balancer_type = "application"
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "tg" {
  name     = "static-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ------------------------------
# Auto Scaling Group
# ------------------------------
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
}

# ------------------------------
# SNS Topic & Email Subscription
# ------------------------------
resource "aws_sns_topic" "cpu_alerts" {
  name = "cpu-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.cpu_alerts.arn
  protocol  = "email"
  endpoint  = "149aishwaryapawar@gmail.com"
}

# ------------------------------
# CloudWatch Alarm for CPU
# ------------------------------
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_sns_topic.cpu_alerts.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

# ------------------------------
# Outputs
# ------------------------------
output "load_balancer_dns" {
  value = aws_lb.alb.dns_name
}
