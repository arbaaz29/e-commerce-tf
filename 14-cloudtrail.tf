# resource "aws_cloudtrail" "main" {
#   name                          = "${var.basename}-cloudtrail"
#   s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
#   include_global_service_events = true
#   is_multi_region_trail         = true
#   enable_log_file_validation    = true
# }

# # S3 Bucket for CloudTrail Logs with Object Ownership
# resource "aws_s3_bucket" "cloudtrail_logs" {
#   bucket = "e-commerce-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
#   acl = "private"
# }

# resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
#   bucket = aws_s3_bucket.cloudtrail_logs.id

#   rule {
#     object_ownership = "BucketOwnerEnforced"
#   }
# }
