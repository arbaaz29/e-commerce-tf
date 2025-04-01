# Corrected Webserver IAM Role and Policy Attachment
resource "aws_iam_role" "webserver_role" {
  name = "WebserverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "webserver_policy" {
  name        = "WebserverPolicy"  # Changed to remove underscore
  description = "Policy to allow EC2 instances to use necessary services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup", 
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:ExecuteStatement",
          "rds:BatchExecuteStatement"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:*"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "webserver_iam_attach" {
  role       = aws_iam_role.webserver_role.name
  policy_arn = aws_iam_policy.webserver_policy.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "WebserverRole"
  role = aws_iam_role.webserver_role.name
}

resource "aws_iam_role" "alb_role" {
  name = "ALBRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "alb_policy" {
  name        = "ALBPolicy"
  description = "Policy to allow ALB to push logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
            "logs:CreateLogGroup", 
            "logs:CreateLogStream", 
            "logs:PutLogEvents"
            ],
        Resource = "*"
      },
      {
        Effect= "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeNetworkInterfaces"
        ],
        Resource = "*"
      },
      # Allow ALB to retrieve ACM certificates for HTTPS termination
      {
        Effect   = "Allow",
        Action   = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:GetCertificate"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:*"
        ],
        Resource = "*"
      }
      
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_policy_attach" {
  role       = aws_iam_role.alb_role.name
  policy_arn = aws_iam_policy.alb_policy.arn
}



resource "aws_iam_role" "waf_logging_role" {
  name = "WAFLoggingRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "waf.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "waf_logging_policy" {
  name        = "WAFLoggingPolicy"
  description = "Policy to allow WAF to send logs to CloudWatch, connect to ALB, and CloudFront"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow WAF to send logs to CloudWatch
      {
        "Action":[
          "wafv2:PutLoggingConfiguration",
          "wafv2:DeleteLoggingConfiguration"
         ],
         "Resource":[
            "*"
         ],
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ],
        Resource = "*"
      },
      # Allow WAF to associate with ALB
      {
        Effect   = "Allow",
        Action   = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth"
        ],
        Resource = "*"
      },
      # Allow WAF to associate with CloudFront
      {
        Effect   = "Allow",
        Action   = [
          "cloudfront:GetDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:GetDistributionConfig",
          "cloudfront:CreateDistribution"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "waf_logging_attach" {
  role       = aws_iam_role.waf_logging_role.name
  policy_arn = aws_iam_policy.waf_logging_policy.arn
}