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
        Resource = aws_kms_key.kms.arn
      },
      # {
      #   Action = [
      #     "*"
      #   ]
      #   Effect   = "Allow"
      #   Resource = "*"
      # },
      # {
      #   Effect   = "Allow"
      #   Action   = "rds-db:connect"
      #   Resource = "${aws_db_instance.rds.arn}/dbuser/e_comm_app"
      # }
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
      # {
      #   Effect   = "Allow",
      #   Action   = [
      #     "secretsmanager:GetSecretValue",
      #     "secretsmanager:DescribeSecret"
      #   ],
      #   Resource = "*"
      # },
      # Allow ALB to describe EC2 instances for target registration
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

# resource "aws_iam_role" "rds_role" {
#   name = "RDSRole"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "rds.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }


# resource "aws_iam_policy" "rds_extended_policy" {
#   name        = "RDSExtendedPolicy"
#   description = "Policy to allow RDS to push logs to CloudWatch, retrieve CA certificates, use KMS, and establish secure MySQL connections"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       # Allow RDS to push logs to CloudWatch
#       {
#         Effect   = "Allow",
#         Action   = [
#           "logs:CreateLogGroup", 
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Resource = "*"
#       },
#       # Allow RDS to retrieve certificates from the default AWS CA
#       {
#         Effect   = "Allow",
#         Action   = [
#           "acm:DescribeCertificate",
#           "acm:ListCertificates",
#           "acm:GetCertificate"
#         ],
#         Resource = "*" # You can restrict this to specific ARNs
#       },
#       # Allow RDS to use KMS for encryption and decryption
#       {
#         Effect   = "Allow",
#         Action   = [
#           "kms:DescribeKey",
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey"
#         ],
#         Resource = "*" # Replace with specific KMS key ARN if needed
#       },
#       # Allow secure MySQL connection (IAM authentication)
#       {
#         Effect   = "Allow",
#         Action   = [
#           "rds:DescribeDBInstances",
#           "rds:Connect"
#         ],
#         Resource = "*" # Restrict this to specific RDS ARN
#       }
#     ]
#   })
# }


# resource "aws_iam_role_policy_attachment" "rds_policy_attach" {
#   role       = aws_iam_role.rds_role.name
#   policy_arn = aws_iam_policy.rds_extended_policy.arn
# }

# resource "aws_iam_instance_profile" "rds" {
#   name = "AWSRDSCustomRole"
#   role = aws_iam_role.rds_role.name
# }



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


# resource "aws_iam_role" "vpc_flow_logs_role" {
#   name = "VPCFlowLogsRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "vpc-flow-logs.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Policy for VPC Flow Logs to CloudWatch
# resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
#   name = "VPCFlowLogsPolicy"
#   role = aws_iam_role.vpc_flow_logs_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:DescribeLogGroups",
#           "logs:DescribeLogStreams"
#         ]
#         Resource = "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }

# # CloudTrail S3 Bucket Policy
# resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
#   bucket = aws_s3_bucket.cloudtrail_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AWSCloudTrailAclCheck"
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudtrail.amazonaws.com"
#         }
#         Action   = "s3:GetBucketAcl"
#         Resource = aws_s3_bucket.cloudtrail_logs.arn
#       },
#       {
#         Sid    = "AWSCloudTrailWrite"
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudtrail.amazonaws.com"
#         }
#         Action   = "s3:PutObject"
#         Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
#         Condition = {
#           StringEquals = {
#             "s3:x-amz-acl" = "bucket-owner-full-control"
#           }
#         }
#       }
#     ]
#   })
# }


# resource "aws_s3_bucket_policy" "alb_bucket_policy" {
#   bucket = aws_s3_bucket.alb_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AWSALBLogs"
#         Effect = "Allow"
#         Principal = {
#           Service = "elasticloadbalancing.amazonaws.com"
#         }
#         Action   = "s3:GetBucketAcl"
#         Resource = aws_s3_bucket.alb_logs.arn
#       },
#       {
#         Sid    = "ALBLogsWrite"
#         Effect = "Allow"
#         Principal = {
#           Service = "elasticloadbalancing.amazonaws.com"
#         }
#         Action   = "s3:PutObject"
#         Resource = "${aws_s3_bucket.alb_logs.arn}/*"
#         Condition = {
#           StringEquals = {
#             "s3:x-amz-acl" = "bucket-owner-full-control"
#           }
#         }
#       }
#     ]
#   })
# }
