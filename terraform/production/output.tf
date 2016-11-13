output "elb_dns_name" {
  value = "${aws_elb.production_pressr_elb.dns_name}"
}

output "rds_dns_name" {
  value = "${module.production_db.rds_mysql_host}"
}
