//symmetric key required to encrypt s3, ebs volumes and RDS 
//Asymmetric needed to encypt keys
//get current users identity
data "aws_caller_identity" "current" {}

//kms key to encrypt ebs, s3, rds 
resource "aws_kms_key" "kms" {
  description              = "Symmetric KMS key for EBS, S3, and RDS encryption"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
  enable_key_rotation      = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Admin"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 and RDS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        },
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
        Sid    = "Allow s3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        },
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
        Sid    = "Allow s3 to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "*",
        Resource = "*"
      }
    ]
  })
}
