variable "ami" {
    description = "AMI ID for the EC2 instance"
    type        = string
    default = "" 
}

variable "instance_type" {
    description = "Type of the EC2 instance"
    type        = string
    default     = ""
}

variable "tag_name" {
    type = string
    default = ""
}

variable "vpc_cidr" {
    type =  string
    default = ""
}