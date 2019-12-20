variable "environment" {}

variable "name" {}

variable "aws_region" {}

variable "instance_class" {}

variable "storage_type" {}

variable "rds_username" {}

#variable "password" {}

variable "allocated_storage" {
  type = number
}

variable "rds_port" {
  type = number
}
