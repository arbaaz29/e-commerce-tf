resource "random_password" "rds" {
  length           = 16
  special         = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "aws_secretsmanager_secret" "database_credentials" {
  name_prefix = "e-commerce/database-credentials-"
  description = "Database credentials for e-commerce application"
  kms_key_id = aws_kms_key.kms_secretmanager.arn
}
resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id     = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    username = var.db_master_username
    password = random_password.rds.result
    endpoint = aws_db_instance.rds.address
    db = var.db_name
    # iam_username = "e_comm_app"
  })
}