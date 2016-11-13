variable "ami_id" {
  default = "ami-cd87c9be"
}
variable "key_name" {}
variable "vpc_security_group_ids" {
  type = "list"
}
variable "subnet_id" {}
variable "availability_zone" {}
variable "instance_count" { default = "2" }
variable "instance_type" {
  default = "t2.small"
}
variable "tags" {
  type = "map"
  default = {}
}
variable "root_size" {
  default = "20"
}
