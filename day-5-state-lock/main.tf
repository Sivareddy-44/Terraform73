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

resource "aws_instance" "web" {
    ami = "ami-0fef201115eefe936"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.dev.id
    tags = {
      Name = "web_instance"
    }
}