variable "resource_prefix" {}
variable "subnet_ids" {
  type = "list"
}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "vpc_security_group_ids" {
  type = "list"
}
variable "environment" {}
