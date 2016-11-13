output "elb_dns_name" {
  value = "${aws_elb.development_pressr_elb.dns_name}"
}

output "rds_dns_name" {
  value = "${module.development_db.rds_mysql_host}"
}
