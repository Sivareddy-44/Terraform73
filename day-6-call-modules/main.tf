module "dev" {
  source = "../day-6-modules"
  ami = "ami-0fef201115eefe936"
  instance_type = "t2.micro"
  tag_name = "dev_instance"
  vpc_cidr = "10.0.0.0/16"
}