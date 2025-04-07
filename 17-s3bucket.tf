//s3 buckets to store access and connection logs for alb
resource "aws_s3_bucket" "alb_access" {
  bucket = "my-alb-logs-ecomm"
}
resource "aws_s3_bucket_ownership_controls" "alb_access" {
  bucket = aws_s3_bucket.alb_access.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "alb_access" {
  depends_on = [ aws_s3_bucket_ownership_controls.alb_access ]
  bucket = aws_s3_bucket.alb_access.id
  acl = "private"
}

resource "aws_s3_bucket_policy" "alb" {
  bucket = aws_s3_bucket.alb_access.id
  policy =jsonencode( {
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
            }
            Action = [
                "s3:PutObject"
            ]
            Resource = "${aws_s3_bucket.alb_access.arn}/*"
        },
        {
            Effect = "Allow"
            Principal = {
                AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action = [
                "s3:*"
            ]
            Resource = "${aws_s3_bucket.alb_access.arn}/*"
        },
        {
            Effect = "Allow",
            Principal = {
            Service = "logdelivery.elasticloadbalancing.amazonaws.com"
            },
            Action = "s3:PutObject",
            Resource = "${aws_s3_bucket.alb_access.arn}/*"
         }
    ]
  })
}

# 4. Enable Bucket Versioning (Optional, for audit purposes)
resource "aws_s3_bucket_versioning" "alb_access_logs_versioning" {
  bucket = aws_s3_bucket.alb_access.id
  versioning_configuration {
    status = "Enabled"
  }
}


