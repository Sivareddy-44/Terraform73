resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name ="vpc_tag"
    }
}

resource "aws_subnet" "dev" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
}