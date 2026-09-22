variable "cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "CIDR block for the VPC"
}

variable "tags" {
    type = string
    default = "my_vpc"
    description = "Tags for the VPC"
}

variable "subnet_cidr" {
    type = string
    default = "10.0.1.0/24"
    description = "CIDR block for the subnet"
}

variable "subnet_tag" {
    type = string
    default = "dev-subnet"
    description = "subnet cidr tags"
}