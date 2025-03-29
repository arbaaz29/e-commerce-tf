# resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
#   alarm_name          = "EC2-CPU-Utilization"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   statistic           = "Average"
#   period              = 300
#   evaluation_periods  = 1
#   threshold           = 80
#   comparison_operator = "GreaterThanThreshold"
#   alarm_description   = "Alarm when EC2 CPU exceeds 80% utilization"
#   dimensions = {
#     InstanceId = aws_instance.webserver["subnet-az1"].id  # EC2 instance ID (subnet-az1)
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
#   alarm_name          = "rds-high-cpu"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/RDS"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 75  # 75% CPU usage
#   alarm_description   = "Triggers when RDS CPU usage exceeds 75%"
#   alarm_actions       = [aws_sns_topic.alerts.arn]
#   ok_actions         = [aws_sns_topic.alerts.arn]

#   dimensions = {
#     DBInstanceIdentifier = aws_db_instance.rds.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "rds_high_latency" {
#   alarm_name          = "rds-high-latency"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "DatabaseConnections"
#   namespace           = "AWS/RDS"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 100 # 100 connections
#   alarm_description   = "Triggers when RDS query latency exceeds threshold"
#   alarm_actions       = [aws_sns_topic.alerts.arn]

#   dimensions = {
#     DBInstanceIdentifier = aws_db_instance.rds.id
#   }
# }

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "ALB-5XX-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1  # 1 error creates alarm
  alarm_description   = "Triggers when ALB 5XX errors exceed threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    LoadBalancer = aws_lb.alb.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_4xx_errors" {
  alarm_name          = "ALB-4XX-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1  # 1 error creates alarm
  alarm_description   = "Triggers when ALB 4XX errors exceed threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    LoadBalancer = aws_lb.alb.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_request_count" {
  alarm_name          = "ALB-Request-Count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000  # 트래픽 요청이 1000을 초과하면 알람
  alarm_description   = "Triggers when ALB request count exceeds threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    LoadBalancer = aws_lb.alb.arn
  }
}

resource "aws_sns_topic" "alerts" {
  name = "alerts-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "arbazij@gmail.com" # sample email
}

resource "aws_cloudwatch_dashboard" "monitoring_dashboard" {
  dashboard_name = "Monitoring-Dashboard"
  # {
    #   "type": "metric",
    #   "x": 0,
    #   "y": 0,
    #   "width": 6,
    #   "height": 6,
    #   "properties": {
    #     "metrics": [
    #       [ "AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.webserver["subnet-az1"].id}" ],
    #       [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${aws_db_instance.rds.id}" ]
    #     ],
    #     "view": "timeSeries",
    #     "stacked": false,
    #     "region": "us-east-1",
    #     "title": "EC2 & RDS CPU Usage"
    #   }
    # },
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 6,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_lb.alb.arn}" ],
          [ "AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", "${aws_lb.alb.arn}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "ALB Error Rates (4XX & 5XX)"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_lb.alb.arn}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "ALB Request Count"
      }
    }
  ]
}
EOF
}
