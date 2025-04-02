resource "aws_autoscaling_group" "asg" {
  name = "deployed-using-terraform"
  max_size = 4
  min_size = 1
  desired_capacity = 1
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  depends_on = [aws_launch_template.webserver, aws_lb.alb]
  launch_template {
    id = aws_launch_template.webserver.id
  }
vpc_zone_identifier = values(aws_subnet.private-subnet)[*].id
enabled_metrics = [
"GroupMinSize",

"GroupMaxSize",

"GroupDesiredCapacity",

"GroupInServiceInstances",

"GroupPendingInstances",

"GroupStandbyInstances",

"GroupTerminatingInstances",

"GroupTotalInstances",

"GroupInServiceCapacity",

"GroupPendingCapacity",

"GroupStandbyCapacity",

"GroupTerminatingCapacity",

"GroupTotalCapacity",

"WarmPoolDesiredCapacity",

"WarmPoolWarmedCapacity",

"WarmPoolPendingCapacity",

"WarmPoolTerminatingCapacity",

"WarmPoolTotalCapacity",

"GroupAndWarmPoolDesiredCapacity",

"GroupAndWarmPoolTotalCapacity"]
metrics_granularity = "1Minute"
}

resource "aws_autoscaling_attachment" "elb_conn" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.tg.arn
}

resource "aws_autoscaling_policy" "asg" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name = "asg_tracking_policy"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }

}

resource "aws_autoscaling_notification" "sns_notification" {
  group_names = [aws_autoscaling_group.asg.id]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.alerts.arn
}