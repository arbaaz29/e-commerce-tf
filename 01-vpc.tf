//create VPC with name e-commerce
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"


  tags = {
    Name      = "${var.basename}-vpc"
    Createdby = "Terraform"
  }
}

# resource "aws_flow_log" "vpc_flow_log" {
#   iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
#   log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.main.id  # Replace with your VPC resource reference
# }

# resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
#   name              = "/aws/vpc/flow-logs"
#   retention_in_days = 30
# }