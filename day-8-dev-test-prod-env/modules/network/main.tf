resource "aws_vpc" "name" {
    cidr_block = var.vpc_cidr
}

resource "aws_subnet" "name" {
    vpc_id     = aws_vpc.name.id
    cidr_block = var.subnet_cidr
}

output "subnet_id" {
    value = aws_subnet.name.id
}