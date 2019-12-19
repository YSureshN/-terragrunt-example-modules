provider "aws" {
  region = var.aws_region

  version = "= 2.42.0"
}

terraform {
  backend "s3" {}
  required_version = "= 0.12.18"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP and SUBNET GROUP FOR THE RDS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  name   = "${var.name}-rds"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group_rule" "rds_allow_sql_inbound" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [data.aws_ssm_parameter.vpc_cidr.value]
  security_group_id = aws_security_group.rds.id
}

resource "aws_db_subnet_group" "mysqlsubnet" {
  name       = "${var.name}-mysqlsubnet"
  subnet_ids = split(",", data.aws_ssm_parameter.db_subnet.value)
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE RDS DB INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "mysql" {
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  name                   = var.name
  username               = var.master_username
  password               = var.master_password
  db_subnet_group_name   = aws_db_subnet_group.mysqlsubnet.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  multi_az               = false

  tags = {
    Name = "${var.name}-mysql"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE SSM PARAMETERS TO USE IN OTHER MODULES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "security_group_rds" {
  name  = "/${var.environment}/security_group_rds"
  type  = "String"
  value = aws_security_group.rds.id
}

resource "aws_ssm_parameter" "dbname" {
  name  = "/${var.environment}/dbname"
  type  = "String"
  value = aws_db_instance.mysql.name
}

resource "aws_ssm_parameter" "dbuser" {
  name  = "/${var.environment}/dbuser"
  type  = "String"
  value = aws_db_instance.mysql.username
}

resource "aws_ssm_parameter" "dbendpoint" {
  name  = "/${var.environment}/dbendpoint"
  type  = "String"
  value = aws_db_instance.mysql.endpoint
}
