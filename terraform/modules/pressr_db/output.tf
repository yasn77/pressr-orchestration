output "rds_mysql_host" {
  value = "${aws_db_instance.pressr_db.address}"
}
