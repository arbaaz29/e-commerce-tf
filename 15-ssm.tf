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


resource "aws_ssm_parameter" "db_iam_username" {
  name  = "/${var.basename}/database/iam_username"
  type  = "SecureString"
  value = "e_comm_app"
}