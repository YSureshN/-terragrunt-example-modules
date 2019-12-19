data "aws_ssm_parameter" "security_group_rds" {
  name = "/${var.environment}/security_group_rds"
}

data "aws_ssm_parameter" "dbname" {
  name = "/${var.environment}/dbname"
}

data "aws_ssm_parameter" "dbuser" {
  name = "/${var.environment}/db-subnet"
}

data "aws_ssm_parameter" "dbendpoint" {
  name = "/${var.environment}/dbendpoint"
}

data "aws_ssm_parameter" "private_subnet" {
  name = "/${var.environment}/private-subnet"
}