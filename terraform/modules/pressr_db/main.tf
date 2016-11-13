resource "aws_db_subnet_group" "default" {
    name = "${format("%s_db", var.resource_prefix)}"
    subnet_ids = ["${var.subnet_ids}"]
    tags {
        Name = "${format("%s_db", var.resource_prefix)}"
    }
}

resource "aws_db_instance" "pressr_db" {
  allocated_storage    = 5
  engine               = "mysql"
  instance_class       = "db.t1.micro"
  name                 = "${var.db_name}"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  backup_retention_period = 2
  multi_az             = true
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  tags = {
    Name = "${format("%s_db", var.resource_prefix)}",
    env = "${var.environment}"
    project = "pressr"
  }

}
