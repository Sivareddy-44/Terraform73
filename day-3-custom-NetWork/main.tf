resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.subnet_cidr
  tags = {
    Name = "dev-subnet-1"
  }
}

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "dev-rt" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }
}

resource "aws_route_table_association" "dev-rt-assoc" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.dev-rt.id
}

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

resource "aws_instance" "public" {
  ami                    = "ami-0fef201115eefe936" # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-1.id
  vpc_security_group_ids = [aws_security_group.dev-sg.id]
  tags = {
    Name = "dev-instance"
  }
}