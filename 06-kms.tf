//symmetric key required to encrypt s3, ebs volumes and RDS 
//Asymmetric needed to encypt keys
//get current users identity
data "aws_caller_identity" "current" {}

//kms key to encrypt ebs 
resource "aws_kms_key" "kms_ebs" {
  description              = "Symmetric KMS key for EBS Encryption"
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
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow region specific EC2 to use the key"
        Effect = "Allow"
        Principal ={
        "AWS" = "*"
        },
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ],
      Resource = "*",
       //this helps resolve the key not found issue, the key should be multi regional or you have to gives access to give access to region specific keys
      Condition =  {
        "StringEquals"= {
          "kms:CallerAccount" = "588738579349",
          "kms:ViaService" = "ec2.us-east-1.amazonaws.com"
        }
      }
    },
      {
        Sid    = "Allow root to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
        "kms:Describe*",
        "kms:Get*",
        "kms:List*",
        "kms:RevokeGrant"
        ],
        Resource = "*"
      }
    ]
  })
}

//kms key to encrypt rds 
resource "aws_kms_key" "kms_rds" {
  description              = "Symmetric KMS key for RDS Encryption"
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
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS to use the key"
        Effect = "Allow"
        Principal ={
        "AWS" = "*"
        },
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ],
      Resource = "*",
      Condition =  {
        "StringEquals"= {
          "kms:CallerAccount" = "588738579349",
          "kms:ViaService" = "rds.us-east-1.amazonaws.com"
        }
      }
    },
      {
        Sid    = "Allow root to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
        "kms:Describe*",
        "kms:Get*",
        "kms:List*",
        "kms:RevokeGrant"
        ],
        Resource = "*"
      }
    ]
  })
}


//kms key to encrypt s3 
resource "aws_kms_key" "kms_s3" {
  description              = "Symmetric KMS key for s3 Encryption"
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
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow s3 to use the key"
        Effect = "Allow"
        Principal ={
        "AWS" = "*"
        },
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ],
      Resource = "*",
      Condition =  {
        "StringEquals"= {
          "kms:CallerAccount" = "588738579349",
          "kms:ViaService" = "s3.us-east-1.amazonaws.com"
        }
      }
    },
      {
        Sid    = "Allow root to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
        "kms:Describe*",
        "kms:Get*",
        "kms:List*",
        "kms:RevokeGrant"
        ],
        Resource = "*"
      }
    ]
  })
}

//kms key to encrypt secretsmanager 
resource "aws_kms_key" "kms_secretmanager" {
  description              = "Symmetric KMS key for RDS Encryption"
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
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow secretamanager to use the key"
        Effect = "Allow"
        Principal ={
        "AWS" = "*"
        },
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ],
      Resource = "*",
      Condition =  {
        "StringEquals"= {
          "kms:CallerAccount" = "588738579349",
          "kms:ViaService" = "secretsmanager.us-east-1.amazonaws.com"
        }
      }
    },
      {
        Sid    = "Allow root to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
        "kms:Describe*",
        "kms:Get*",
        "kms:List*",
        "kms:RevokeGrant"
        ],
        Resource = "*"
      }
    ]
  })
  }


//kms key to encrypt acm 
resource "aws_kms_key" "kms_acm" {
  description              = "Symmetric KMS key for RDS Encryption"
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
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
        },
        Action   = "kms:*"
        Resource = "*"
      },
    {
      "Sid": "Allow creation of decryption grants",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "kms:CreateGrant",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "acm.us-east-1.amazonaws.com",
          "kms:CallerAccount": "588738579349"
        },
        "ForAllValues:StringEquals": {
          "kms:GrantOperations": "Decrypt"
        },
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Sid": "Allow creation of encryption grant",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "kms:CreateGrant",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "acm.us-east-1.amazonaws.com",
          "kms:CallerAccount": "588738579349"
        },
        "ForAllValues:StringEquals": {
          "kms:GrantOperations": [
            "Encrypt",
            "ReEncryptFrom",
            "ReEncryptTo"
          ]
        },
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Sid": "Allowed operations for the key owner",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "kms:DescribeKey",
        "kms:ListGrants",
        "kms:RevokeGrant",
        "kms:GetKeyPolicy"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "588738579349"
        }
      }
    },
    {
      "Sid": "Deny re-encryption to any other key",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "kms:ReEncrypt*",
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:ReEncryptOnSameKey": "false"
        }
      }
    },
    {
      "Sid": "Allow decrypt",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "kms:Decrypt",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "acm.us-east-1.amazonaws.com",
          "kms:CallerAccount": "588738579349"
        }
      }
    },
      {
        Sid    = "Allow root to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
        "kms:Describe*",
        "kms:Get*",
        "kms:List*",
        "kms:RevokeGrant"
        ],
        Resource = "*"
      }
    ]
  })
  }

//alias for keys

  resource "aws_kms_alias" "kms_ebs" {
    name_prefix = "alias/ebs-"
    target_key_id = aws_kms_key.kms_ebs.arn
  }

  
  resource "aws_kms_alias" "kms_rds" {
    name_prefix = "alias/rds-"
    target_key_id = aws_kms_key.kms_rds.arn
  }

  
  resource "aws_kms_alias" "kms_s3" {
    name_prefix = "alias/s3-"
    target_key_id = aws_kms_key.kms_s3.arn
  }

  
  resource "aws_kms_alias" "kms_secretmanager" {
    name_prefix = "alias/secretsmanager-"
    target_key_id = aws_kms_key.kms_secretmanager.arn
  }

  
  resource "aws_kms_alias" "kms_acm" {
    name_prefix = "alias/ebs-"
    target_key_id = aws_kms_key.kms_acm.arn
  }