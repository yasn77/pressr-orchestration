variable "access_key" {}
variable "secret_key" {}
variable "ami_id" { default = "ami-cd87c9be" }
variable "sshpubkey_file" { default = "sshpub.key" }
variable "resource_prefix" { default = "yasser_nabi_pressr" }
variable "region" { default = "eu-west-1" }
variable "cidr_block" { default = "172.16.0.0/16" }
variable "primary_subnet" { default = "172.16.19.0/24" }
variable "secondary_subnet" { default = "172.16.29.0/24" }
variable "db_username" { default = "pressr" }
variable "db_password" {}
