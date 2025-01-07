#Generate Key
resource "aws_key_pair" "maged-key" {
    key_name = "maged-key"
    public_key = file(var.path_to_public_key)
}

# Launch Template
resource "aws_launch_template" "maged-wordpress-tf" {
  name          = var.template-name
  image_id      = var.template-image
  instance_type = var.template-instance-type
  vpc_security_group_ids = [aws_security_group.maged-wordpress-terraform-sg.id]

  # Add optional tags
  tags = {
    Name = var.template-tag
  }
}

# Create Load Balancer
resource "aws_lb" "maged-wordpress-alb" {
  name               = var.lb-name
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.maged-wordpress-terraform-sg.id]
  subnets            = [var.subnet_1a_id, var.subnet_1b_id]
  enable_deletion_protection = false
  tags = {
    Name = var.lb-tag
  }
}
# Create Target Group for WordPress
resource "aws_lb_target_group" "maged-wordpress-tg" {
  name     = "maged-wordpress-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Name = "maged-wordpress-tg"
  }
}
# Create Load Balancer Listener
resource "aws_lb_listener" "maged-wordpress-listener" {
  load_balancer_arn = aws_lb.maged-wordpress-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.maged-wordpress-tg.arn
  }
}


#Autoscaling Group
resource "aws_autoscaling_group" "maged-autoscaling" {
  name                      = "maged-autoscaling"
  vpc_zone_identifier       = [var.subnet_1a_id, var.subnet_1b_id]
  launch_template {
    id      = aws_launch_template.maged-wordpress-tf.id
  }
  min_size                  = 2
  max_size                  = 3
  health_check_grace_period = 200
  health_check_type         = "EC2"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.maged-wordpress-tg.arn] 
  tag {
    key                 = "Name"
    value               = "maged-terraform-wordpress-scaling"
    propagate_at_launch = true
  }
}

#Autoscaling Configuration policy - Scaling Alarm
resource "aws_autoscaling_policy" "maged-cpu-policy" {
  name                   = "maged-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.maged-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "200"
  policy_type            = "SimpleScaling"
}

#Auto scaling Cloud Watch Monitoring
resource "aws_cloudwatch_metric_alarm" "maged-cpu-alarm" {
  alarm_name          = "maged-cpu-alarm"
  alarm_description   = "Alarm once CPU Uses Increase"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.maged-autoscaling.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.maged-cpu-policy.arn]
}

#Auto Descaling Policy
resource "aws_autoscaling_policy" "maged-cpu-policy-scaledown" {
  name                   = "maged-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.maged-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "200"
  policy_type            = "SimpleScaling"
}

#Auto descaling cloud watch 
resource "aws_cloudwatch_metric_alarm" "maged-cpu-alarm-scaledown" {
  alarm_name          = "maged-cpu-alarm-scaledown"
  alarm_description   = "Alarm once CPU Uses Decrease"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.maged-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.maged-cpu-policy-scaledown.arn]
}