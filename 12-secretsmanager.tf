resource "random_password" "rds" {
  length           = 16
  special         = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "aws_secretsmanager_secret" "database_credentials" {
  name = "${var.basename}/database-credentials-${var.secretnumber}" #don't forget to change the name in bash script or your script will fail to verify
  description = "Database credentials for e-commerce application"
  kms_key_id = aws_kms_key.kms.arn
}
resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id     = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds.result
    endpoint = aws_db_instance.rds.address
    db = "ecomdb" # remove if any problems
    iam_username = "e_comm_app"
  })
}