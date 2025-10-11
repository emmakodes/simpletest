resource "aws_ssm_parameter" "db_url" {
  name  = "/todo/${var.env}/DATABASE_URL"
  type  = "SecureString"
  value = "postgresql://app:app-password-change@${aws_db_instance.postgres.address}:5432/todo"
}

resource "aws_ssm_parameter" "jwt_secret" {
  name  = "/todo/${var.env}/JWT_SECRET"
  type  = "SecureString"
  value = "change-me"
}


