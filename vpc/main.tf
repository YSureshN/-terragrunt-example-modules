provider "aws" {
  region = var.aws_region

  version = "= 2.42.0"
}

terraform {
  backend "s3" {}
  required_version = "= 0.12.18"
}


#Creating VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  tags = {
    Name = "${var.name}-vpc"
  }
}

#Internet gateway
resource "aws_internet_gateway" "public_gateway" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.name}--internet public gw"
  }
}

#Route table: public
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = var.public_route
    gateway_id = aws_internet_gateway.public_gateway.id
  }
  tags = {
    Name = "${var.name}-public route table"
  }
}

#Subnets: public
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public subnet-${count.index + 1}"
  }
}

#Route table associations: public
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route.id
  depends_on     = [aws_route_table.public_route]
}

#Subnets: private
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = element(var.private_subnets_cidr, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name}-private subnet-${count.index + 1}"
  }
}

#EIP: allocation elastic ips for nat gateway
resource "aws_eip" "nat_eip" {
  count = length(aws_subnet.private_subnet)
  vpc   = true
}

#NAT gateway
resource "aws_nat_gateway" "nat-gw" {
  count         = length(var.public_subnets_cidr)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  depends_on    = [aws_eip.nat_eip]

}

#Route table: private
resource "aws_route_table" "private_route" {
  count      = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.myvpc.id
  depends_on = [aws_nat_gateway.nat-gw]
  route {
    cidr_block     = var.public_route
    nat_gateway_id = element(aws_nat_gateway.nat-gw.*.id, count.index)
  }
  tags = {
    Name = "${var.name}-private route table-${count.index + 1}"
  }
}

#Route table associations: private
resource "aws_route_table_association" "association-private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)
  depends_on     = [aws_route_table.private_route]
}

#Subnets: database
resource "aws_subnet" "db_subnet" {
  count                   = length(var.db_subnets_cidr)
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = element(var.db_subnets_cidr, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name}-db subnet-${count.index + 1}"
  }
}

#Route table: database
resource "aws_route_table" "db_route" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.name}-db route table"
  }
}

#Route table association: database
resource "aws_route_table_association" "db-association" {
  count          = length(var.db_subnets_cidr)
  subnet_id      = element(aws_subnet.db_subnet.*.id, count.index)
  route_table_id = aws_route_table.db_route.id
  depends_on     = [aws_route_table.db_route]
}


resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.name}/vpc_id"
  type  = "String"
  value = aws_vpc.myvpc.id
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name  = "/${var.name}/vpc_cidr"
  type  = "String"
  value = aws_vpc.myvpc.cidr_block
}

resource "aws_ssm_parameter" "public_subnet" {
  name  = "/${var.name}/public-subnet"
  type  = "StringList"
  value = aws_subnet.public_subnet.0.id,aws_subnet.public_subnet.1.id
}

resource "aws_ssm_parameter" "private_subnet" {
  name  = "/${var.name}/private-subnet"
  type  = "StringList"
  value = aws_subnet.private_subnet.0.id,aws_subnet.private_subnet.1.id
}

resource "aws_ssm_parameter" "db_subnet" {
  name  = "/${var.name}/db-subnet"
  type  = "StringList"
  value = aws_subnet.db_subnet.0.id,aws_subnet.db_subnet.1.id
}
