resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "dev-vpc"
  }
}

# -------------------------
# Public Subnet
# -------------------------
resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.subnet_cidr_1
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-subnet-1-public"
  }
}

# -------------------------
# Private Subnet
# -------------------------
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.subnet_cidr_2

  tags = {
    Name = "dev-subnet-2-private"
  }
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-igw"
  }
}

# -------------------------
# Public Route Table
# -------------------------
resource "aws_route_table" "dev-rt" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "dev-public-rt"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "dev-rt-assoc" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.dev-rt.id
}

# -------------------------
# Elastic IP for NAT Gateway
# -------------------------
resource "aws_eip" "dev-nat-eip" {
  domain = "vpc"

  tags = {
    Name = "dev-nat-eip"
  }
}

# -------------------------
# NAT Gateway
# -------------------------
# NAT Gateway MUST be in the public subnet
resource "aws_nat_gateway" "dev-nat-gw" {
  allocation_id = aws_eip.dev-nat-eip.id
  subnet_id     = aws_subnet.subnet-1.id

  depends_on = [
    aws_internet_gateway.dev-igw
  ]

  tags = {
    Name = "dev-nat-gw"
  }
}

# -------------------------
# Private Route Table
# -------------------------
resource "aws_route_table" "dev-nat-rt" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev-nat-gw.id
  }

  tags = {
    Name = "dev-private-rt"
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "dev-nat-rt-assoc" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.dev-nat-rt.id
}

# -------------------------
# Security Group
# -------------------------
resource "aws_security_group" "dev-sg" {
  name        = "dev-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-sg"
  }
}

# -------------------------
# EC2 Instance
# -------------------------
resource "aws_instance" "public" {
  ami                         = "ami-0fef201115eefe936"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = [aws_security_group.dev-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "dev-instance"
  }
}