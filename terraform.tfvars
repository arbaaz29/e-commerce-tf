vpc_cidr = "10.0.0.0/16"
tag_name = "midterms"
basename = "e-commerce"
db_master_username = "admin"
db_name = "ecomdb"
public_subnet_cidrs = {
  subnet-az1 = {
    az   = "us-east-1a"
    cidr = "10.0.1.0/24"
    idx  = 1
  }
  subnet-az2 = {
    az   = "us-east-1b"
    cidr = "10.0.6.0/24"
    idx  = 2
  }
}
private_subnet_cidrs = {
  subnet-az1 = {
    az   = "us-east-1a" //dynamic label to identify us-east-az1
    cidr = "10.0.60.0/24"
    idx  = 1
  }
  subnet-az2 = {
    az   = "us-east-1b" //dynamic label to identify us-east-az2
    cidr = "10.0.120.0/24"
    idx  = 2
  }
}
private_subnet_cidrs_rds = {
  subnet-az1 = {
    az   = "us-east-1a" //dynamic label to identify us-east-az1
    cidr = "10.0.180.0/24"
    idx  = 1
  }
  subnet-az2 = {
    az   = "us-east-1b" //dynamic label to identify us-east-az2
    cidr = "10.0.240.0/24"
    idx  = 2
  }
}
instance_type_value = "t2.micro"
rds_instance_type = "db.t3.micro"


































# admin_role = {
#   sid = 1
#   actions = [
#     "s3:*",
#     "ec2:*",
#     "sts:AssumeRole",
# "apigateway:GET",
#                 "apigateway:SetWebACL",
#                 "cloudfront:ListDistributions",
#                 "cloudfront:ListDistributionsByWebACLId",
#                 "cloudfront:UpdateDistribution",
#                 "cloudwatch:GetMetricData",
#                 "cloudwatch:GetMetricStatistics",
#                 "cloudwatch:ListMetrics",
#                 "ec2:DescribeRegions",
#                 "elasticloadbalancing:DescribeLoadBalancers",
#                 "elasticloadbalancing:SetWebACL",
#                 "appsync:ListGraphqlApis",
#                 "appsync:SetWebACL",
#                 "waf-regional:*",
#                 "waf:*",
#                 "wafv2:*",
#                 "s3:ListAllMyBuckets",
#                 "logs:DescribeResourcePolicies",
#                 "logs:DescribeLogGroups",
#                 "cognito-idp:ListUserPools",
#                 "cognito-idp:AssociateWebACL",
#                 "cognito-idp:DisassociateWebACL",
#                 "cognito-idp:ListResourcesForWebACL",
#                 "cognito-idp:GetWebACLForResource",
#                 "apprunner:AssociateWebAcl",
#                 "apprunner:DisassociateWebAcl",
#                 "apprunner:DescribeWebAclForService",
#                 "apprunner:ListServices",
#                 "apprunner:ListAssociatedServicesForWebAcl",
#                 "ec2:AssociateVerifiedAccessInstanceWebAcl",
#                 "ec2:DisassociateVerifiedAccessInstanceWebAcl",
#                 "ec2:DescribeVerifiedAccessInstanceWebAclAssociations",
#                 "ec2:GetVerifiedAccessInstanceWebAcl",
#                 "ec2:DescribeVerifiedAccessInstances"
#   ]
# }