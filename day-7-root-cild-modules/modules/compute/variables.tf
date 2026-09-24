variable "ami" {
    description = "The AMI ID for the instance"
    type        = string
    default     = ""  
}

variable "instance_type" {
    description = "The instance type for the instance"
    type        = string
    default     = ""
}

variable "subnet_id" {
    description = "The subnet ID for the instance"
    type        = string
    default     = ""
}