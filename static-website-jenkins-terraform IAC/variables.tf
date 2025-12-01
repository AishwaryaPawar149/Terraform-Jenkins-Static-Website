variable "aws_region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "terraform"   # existing keypair name
}

variable "ami_id" {
  default = "ami-0ade68f094cc81635"   # Ubuntu 22.04 LTS for ap-south-1
}
