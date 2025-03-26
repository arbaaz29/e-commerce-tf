resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "web-acl"
  description = "WAF for ALB"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  rule {
    name     = "BlockBadBots"
    priority = 1
    action {
      block {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }
        positional_constraint = "CONTAINS"
        search_string         = "/admin"
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockBadBots"
      sampled_requests_enabled   = true
    }
  }
  # rule_json = [
  #   {
  #     "Name": "AWS-AWSManagedRulesLinuxRuleSet",
  #     "Priority": 0,
  #     "Statement": {
  #       "ManagedRuleGroupStatement": {
  #         "VendorName": "AWS",
  #         "Name": "AWSManagedRulesLinuxRuleSet"
  #       }
  #     },
  #     "OverrideAction": {
  #       "None": {}
  #     },
  #     "VisibilityConfig": {
  #       "SampledRequestsEnabled": true,
  #       "CloudWatchMetricsEnabled": true,
  #       "MetricName": "AWS-AWSManagedRulesLinuxRuleSet"
  #     }
  #   },
  #   {
  #     "Name": "AWS-AWSManagedRulesKnownBadInputsRuleSet",
  #     "Priority": 1,
  #     "Statement": {
  #       "ManagedRuleGroupStatement": {
  #         "VendorName": "AWS",
  #         "Name": "AWSManagedRulesKnownBadInputsRuleSet"
  #       }
  #     },
  #     "OverrideAction": {
  #       "None": {}
  #     },
  #     "VisibilityConfig": {
  #       "SampledRequestsEnabled": true,
  #       "CloudWatchMetricsEnabled": true,
  #       "MetricName": "AWS-AWSManagedRulesKnownBadInputsRuleSet"
  #     }
  #   },
  #   {
  #     "Name": "AWS-AWSManagedRulesSQLiRuleSet",
  #     "Priority": 2,
  #     "Statement": {
  #       "ManagedRuleGroupStatement": {
  #         "VendorName": "AWS",
  #         "Name": "AWSManagedRulesSQLiRuleSet"
  #       }
  #     },
  #     "OverrideAction": {
  #       "None": {}
  #     },
  #     "VisibilityConfig": {
  #       "SampledRequestsEnabled": true,
  #       "CloudWatchMetricsEnabled": true,
  #       "MetricName": "AWS-AWSManagedRulesSQLiRuleSet"
  #     }
  #   },
  #   {
  #     "Name": "AWS-AWSManagedRulesPHPRuleSet",
  #     "Priority": 3,
  #     "Statement": {
  #       "ManagedRuleGroupStatement": {
  #         "VendorName": "AWS",
  #         "Name": "AWSManagedRulesPHPRuleSet"
  #       }
  #     },
  #     "OverrideAction": {
  #       "None": {}
  #     },
  #     "VisibilityConfig": {
  #       "SampledRequestsEnabled": true,
  #       "CloudWatchMetricsEnabled": true,
  #       "MetricName": "AWS-AWSManagedRulesPHPRuleSet"
  #     }
  #   }]

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl-metrics"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_regex_pattern_set" "bad_inputs" {
  name  = "bad-inputs-pattern"
  scope = "REGIONAL"

  regular_expression {
    regex_string = "(?i)(select\\s.*from|union\\s+select|<script>|javascript:|alert\\(|document\\.cookie)"
  }

  tags = {
    Name = "bad-inputs-pattern"
  }
}

resource "aws_wafv2_web_acl_association" "waf_assoc" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
  
  depends_on = [ aws_wafv2_web_acl.waf_acl, aws_instance.webserver ]
}

# resource "aws_cloudwatch_log_group" "waf_logs" {
#   name = "${var.basename}-aws-waf-logs"
# }

# resource "aws_wafv2_web_acl_logging_configuration" "waf_logs" {
#   log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
#   resource_arn = aws_wafv2_web_acl.waf_acl.arn
# }

# data "aws_iam_policy_document" "waf_logs" {
#   version = "2012-10-17"
#   statement {
#     effect = "Allow"
#     principals {
#       identifiers = ["delivery.logs.amazonaws.com"]
#       type        = "Service"
#     }
#     actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
#     resources = ["${aws_cloudwatch_log_group.waf_logs.arn}:*"]
#     condition {
#       test     = "ArnLike"
#       values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
#       variable = "aws:SourceArn"
#     }
#     condition {
#       test     = "StringEquals"
#       values   = [tostring(data.aws_caller_identity.current.account_id)]
#       variable = "aws:SourceAccount"
#     }
#   }
# }

# data "aws_region" "current" {}