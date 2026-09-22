resource "aws_vpc" "dev" {
    cidr_block = var.cidr
    tags = {
      Name = var.tags
    }
}

resource "aws_subnet" "dev_subnet" {
    vpc_id = aws_vpc.dev.id
    cidr_block = var.subnet_cidr
    tags = {
      Name = var.subnet_tag
    }
}