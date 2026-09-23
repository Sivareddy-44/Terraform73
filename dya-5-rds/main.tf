# ============================================================
# PROVIDER
# ============================================================

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}


# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dev-vpc"
  }
}


# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.name.id

  tags = {
    Name = "my-igw"
  }
}


# ============================================================
# PUBLIC SUBNET - 1
# ============================================================

resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.name.id

  cidr_block = "10.0.0.0/24"

  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet-1"
  }
}


# ============================================================
# PUBLIC SUBNET - 2
# ============================================================

resource "aws_subnet" "subnet-2" {
  vpc_id = aws_vpc.name.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "us-east-1b"

  tags = {
    Name = "public-subnet-2"
  }
}


# ============================================================
# PRIVATE SUBNET - 1
# ============================================================

resource "aws_subnet" "private-subnet-1" {
  vpc_id = aws_vpc.name.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}


# ============================================================
# PRIVATE SUBNET - 2
# ============================================================

resource "aws_subnet" "private-subnet-2" {
  vpc_id = aws_vpc.name.id

  cidr_block = "10.0.3.0/24"

  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}


# ============================================================
# PUBLIC ROUTE TABLE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.name.id
  }

  tags = {
    Name = "public-route-table"
  }
}


# ============================================================
# PUBLIC SUBNET ROUTE TABLE ASSOCIATION
# ============================================================

resource "aws_route_table_association" "subnet-1" {
  subnet_id = aws_subnet.subnet-1.id

  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "subnet-2" {
  subnet_id = aws_subnet.subnet-2.id

  route_table_id = aws_route_table.public.id
}


# ============================================================
# ELASTIC IP FOR NAT GATEWAY
# ============================================================

resource "aws_eip" "dev-nat-eip" {
  domain = "vpc"

  tags = {
    Name = "dev-nat-eip"
  }
}


# ============================================================
# NAT GATEWAY
# ============================================================

resource "aws_nat_gateway" "dev-nat-gw" {
  allocation_id = aws_eip.dev-nat-eip.id

  subnet_id = aws_subnet.subnet-1.id

  depends_on = [
    aws_internet_gateway.name
  ]

  tags = {
    Name = "dev-nat-gateway"
  }
}


# ============================================================
# PRIVATE ROUTE TABLE
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.dev-nat-gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}


# ============================================================
# PRIVATE SUBNET ROUTE TABLE ASSOCIATIONS
# ============================================================

resource "aws_route_table_association" "private-subnet-1" {
  subnet_id = aws_subnet.private-subnet-1.id

  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "private-subnet-2" {
  subnet_id = aws_subnet.private-subnet-2.id

  route_table_id = aws_route_table.private.id
}


# ============================================================
# RDS SUBNET GROUP
# ============================================================

resource "aws_db_subnet_group" "my_subnet_group" {
  name = "my-subnet-group"

  subnet_ids = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]

  tags = {
    Name = "my-rds-subnet-group"
  }
}


# ============================================================
# SECURITY GROUP
# ============================================================

resource "aws_security_group" "my_security_group" {
  name = "my-security-group"

  description = "Allow MySQL traffic"

  vpc_id = aws_vpc.name.id

  # MySQL
  ingress {
    from_port = 3306

    to_port = 3306

    protocol = "tcp"

    cidr_blocks = [
      "10.0.0.0/16"
    ]
  }

  # Outbound traffic
  egress {
    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "rds-security-group"
  }
}


# ============================================================
# PRIMARY RDS DATABASE
# ============================================================

resource "aws_db_instance" "primary" {

  allocated_storage = 20

  engine = "mysql"

  engine_version = "8.0"

  instance_class = "db.t3.micro"

  identifier = "mydbinstance"

  username = "admin"

  password = "Cloud123"

  db_subnet_group_name = aws_db_subnet_group.my_subnet_group.name

  vpc_security_group_ids = [
    aws_security_group.my_security_group.id
  ]

  publicly_accessible = false

  skip_final_snapshot = true

  maintenance_window = "Mon:00:00-Mon:03:00"

  backup_retention_period = 7

  tags = {
    Name = "primary-rds"
  }
}


# ============================================================
# RDS READ REPLICA
# ============================================================

resource "aws_db_instance" "replica" {

  identifier = "mydb-replica"

  replicate_source_db = aws_db_instance.primary.arn

  instance_class = "db.t3.micro"

  db_subnet_group_name = aws_db_subnet_group.my_subnet_group.name

  vpc_security_group_ids = [
    aws_security_group.my_security_group.id
  ]

  publicly_accessible = false

  skip_final_snapshot = true

  backup_retention_period = 7

  maintenance_window = "Tue:00:00-Tue:03:00"

  tags = {
    Name = "rds-read-replica"
  }
}