data "aws_availability_zones" "available" {}

variable "access_key" {}
variable "secret_key" {}
variable "sshpubkey_file" { default = "sshpub.key" }
variable "region" { default = "eu-west-1" }
variable "ami_id" {
  default = "ami-0d77397e"
}
variable "instance_type" {
  default = "t2.small"
}
variable "root_disk_size" {
  default = "25"
}
variable "db_username" { default = "pressr" }
variable "db_password" {}
# Instance count, per availability zone
variable "app_instance_count" { default = "2" }
variable "haproxy_instance_count" { default = "1" }
variable "consul_instance_count" { default = "2" }
variable "environment" {}
variable "resource_prefix" {}
variable "cidr_block" {}
variable "primary_subnet" {}
variable "secondary_subnet" {}
variable "db_name" {}
