data "aws_ssm_parameter" "vpc_cidr" {
  name = "/${var.name}/vpc_cidr"
}

data "aws_ssm_parameter" "db_subnet" {
  name = "/${var.name}/db-subnet"
}
