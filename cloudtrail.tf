resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cloudtrail_policy" {
  name        = "CloudTrailLogsPolicy"
  description = "Policy for CloudTrail to write logs to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "cloudtrail_policy_attachment" {
  name       = "cloudtrail-logs-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_policy.arn
  roles      = [aws_iam_role.cloudtrail_role.name]
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = "/aws/cloudtrail/main-log-group"
  retention_in_days = 1
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "ecomm-cloudtrail-log-bucket"
}

// !! NEED MANUAL SETTING FOR Cloudtrail !!

# resource "aws_cloudtrail" "main" {
#   name                          = "main-cloudtrail"
#   s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
#   cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail_log_group.arn  // InvalidCloudWatchLogsLogGroupArnException: CloudTrail cannot validate the specified log group ARN.
#   cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn

#   depends_on = [
#     aws_s3_bucket.cloudtrail_logs,
#     aws_cloudwatch_log_group.cloudtrail_log_group,
#     aws_iam_role.cloudtrail_role
#   ]
# }
