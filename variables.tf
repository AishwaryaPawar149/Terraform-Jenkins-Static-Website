variable "region" {}
variable "ami_id" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "security_group_id" {}
variable "key_name" {}
