resource "aws_vpc" "dev" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = "dev_vpc"
    }
}

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.dev.id
    cidr_block = var.subnet_cidr
    tags = {
      Name = "dev_subnet_1"
    }
}

resource "aws_instance" "web" {
    ami = "ami-0fef201115eefe936"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet-1.id
    tags = {
      Name = "dev_web_instance"
    }
}

resource "aws_s3_bucket" "bucket" {
    bucket = "dev-terraform-bucket-8907"
  
}