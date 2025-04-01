resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "web-acl"
  description = "WAF for ALB"
  scope       = "REGIONAL"
  
  default_action {
    allow {}
  }
  
  rule {
    name     = "BlockBadBots"
    priority = 4
    action {
      block {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }
        positional_constraint = "CONTAINS"
        search_string         = "/waf"
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
  
  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 0
    
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesLinuxRuleSet"
      }
    }
    
    override_action {
      none {}
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1
    
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }
    
    override_action {
      none {}
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 2
    
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }
    
    override_action {
      none {}
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  rule {
    name     = "AWS-AWSManagedRulesPHPRuleSet"
    priority = 3
    
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesPHPRuleSet"
      }
    }
    
    override_action {
      none {}
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesPHPRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ecom_waf"
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
  
  depends_on = [aws_wafv2_web_acl.waf_acl, aws_instance.webserver]
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  name = "aws-waf-logs-${var.basename}"
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logs" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn = aws_wafv2_web_acl.waf_acl.arn
}
