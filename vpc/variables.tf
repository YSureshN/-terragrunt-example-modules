# data "aws_availability_zones" "available" {
#   state = "available"
# }
#-------------------------------------------
variable "aws_region" {
  default = ""
}

variable "environment" {
  default = ""
}

variable "name" {
  default = ""
}

variable "vpc_cidr" {
  default = ""
}

variable "public_subnets_cidr" {
  type        = "list"
  default     = []
  description = "cidr blocks of public subnets with full access to internet"
}

variable "private_subnets_cidr" {
  type        = "list"
  default     = []
  description = "cidr blocks of private subnets with access through NAT"
}

variable "db_subnets_cidr" {
  type        = "list"
  default     = []
  description = "cidr blocks of db subnets with no access to internet"
}
