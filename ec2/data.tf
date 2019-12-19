data "aws_ssm_parameter" "security_group_rds" {
  name = "/${var.name}/security_group_rds"
}

data "aws_ssm_parameter" "dbname" {
  name = "/${var.name}/dbname"
}

data "aws_ssm_parameter" "dbuser" {
  name = "/${var.name}/db-subnet"
}

data "aws_ssm_parameter" "dbendpoint" {
  name = "/${var.name}/dbendpoint"
}

data "aws_ssm_parameter" "private_subnet" {
  name = "/${var.name}/private-subnet"
}
