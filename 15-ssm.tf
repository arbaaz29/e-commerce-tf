resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/${var.basename}/database/endpoint"
  type  = "SecureString"
  value = aws_db_instance.rds.address
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.basename}/database/username"
  type  = "SecureString"
  value = "admin"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.basename}/database/password"
  type  = "SecureString"
  value = random_password.rds.result
}

resource "aws_ssm_parameter" "db_db" {
  name  = "/${var.basename}/database/db"
  type  = "SecureString"
  value = "ecomdb"
}

resource "aws_iam_role_policy" "ssm_access" {
  name = "ssm-parameter-access-policy"
  role = aws_iam_role.webserver_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}