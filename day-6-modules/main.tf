#module for ec2 instance
resource "aws_instance" "name" {
    ami           = var.ami
    instance_type = var.instance_type
    tags = {
        Name = var.tag_name
    }
}

resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "dev_vpc"
  }
}