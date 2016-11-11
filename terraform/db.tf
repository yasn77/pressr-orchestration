resource "aws_db_subnet_group" "default" {
    name = "${format("%s_db", var.resource_prefix)}"
    subnet_ids = ["${aws_subnet.primary.id}", "${aws_subnet.secondary.id}"]
    tags {
        Name = "${format("%s_db", var.resource_prefix)}"
    }
}

resource "aws_db_instance" "pressr_db" {
  allocated_storage    = 5
  engine               = "mysql"
  instance_class       = "db.t1.micro"
  name                 = "pressr_db"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  backup_retention_period = 2
  multi_az             = true
  vpc_security_group_ids = ["${aws_security_group.db.id}"]

}
