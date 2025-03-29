# //access_logs
# # 1. Create the S3 Bucket for ALB Logs
# resource "aws_s3_bucket" "alb_logs" {
#   bucket = "e-comm-alb-logs-bucket"
# }

# # 2. Enable Server-Side Encryption
# resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs_encryption" {
#   bucket = aws_s3_bucket.alb_logs.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # 3. Set Bucket Policy to Allow ALB to Write Logs
# resource "aws_s3_bucket_policy" "alb_logs_policy" {
#   bucket = aws_s3_bucket.alb_logs.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#       }
#       Action   = "s3:PutObject"
#       Resource = "${aws_s3_bucket.alb_logs.arn}/AWSLogs/*"
#     }]
#   })
# }

# # 4. Enable Bucket Versioning (Optional, for audit purposes)
# resource "aws_s3_bucket_versioning" "alb_logs_versioning" {
#   bucket = aws_s3_bucket.alb_logs.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# //connection_logs
# # 1. Create the S3 Bucket for ALB Logs
# resource "aws_s3_bucket" "alb_connection_logs" {
#   bucket = "e-comm-alb-connection-logs-bucket"
# }

# # 2. Enable Server-Side Encryption
# resource "aws_s3_bucket_server_side_encryption_configuration" "alb_connection_logs_encryption" {
#   bucket = aws_s3_bucket.alb_connection_logs.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # 3. Set Bucket Policy to Allow ALB to Write Logs
# resource "aws_s3_bucket_policy" "alb_connection_logs_policy" {
#   bucket = aws_s3_bucket.alb_connection_logs.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#       }
#       Action   = "s3:PutObject"
#       Resource = "${aws_s3_bucket.alb_connection_logs.arn}/AWSLogs/*"
#     }]
#   })
# }

# # 4. Enable Bucket Versioning (Optional, for audit purposes)
# resource "aws_s3_bucket_versioning" "alb_connection_logs_versioning" {
#   bucket = aws_s3_bucket.alb_connection_logs.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }


