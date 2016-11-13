provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "auth" {
  public_key = "${file(var.sshpubkey_file)}"
}

resource "aws_elb" "development_pressr_elb" {
  name = "development-pressr-elb"

  subnets         = ["${aws_subnet.development_primary.id}","${aws_subnet.development_secondary.id}"]
  security_groups = ["${aws_security_group.development_elb.id}"]
  instances       = ["${module.development_haproxy_instance_primary_az.id_list}", "${module.development_haproxy_instance_secondary_az.id_list}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

module "development_db" {
  source = "../modules/pressr_db"
  resource_prefix = "${var.resource_prefix}"
  subnet_ids = ["${aws_subnet.development_primary.id}", "${aws_subnet.development_secondary.id}"]
  db_name = "${var.db_name}"
  db_username = "${var.db_username}"
  db_password = "${var.db_password}"
  vpc_security_group_ids = ["${aws_security_group.development_db.id}"]
  environment = "${var.environment}"
}

module "development_app_instance_primary_az" {
  source = "../modules/pressr_instance"
  ami_id = "${var.ami_id}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.development_app.id}"]
  instance_count = "${var.app_instance_count}"
  root_size = "${var.root_disk_size}"
  instance_type = "${var.instance_type}"
  tags = {
    "role" = "app",
    "env" = "${var.environment}"
    "availability_zone" = "${aws_subnet.development_primary.availability_zone}"
    "rds_mysql" = "${module.development_db.rds_mysql_host}"
  }
  availability_zone = "${aws_subnet.development_primary.availability_zone}"
  subnet_id = "${aws_subnet.development_primary.id}"
}

module "development_app_instance_secondary_az" {
  source = "../modules/pressr_instance"
  ami_id = "${var.ami_id}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.development_app.id}"]
  instance_count = "${var.app_instance_count}"
  root_size = "${var.root_disk_size}"
  instance_type = "${var.instance_type}"
  tags = {
    "role" = "app",
    "env" = "${var.environment}"
    "availability_zone" = "${aws_subnet.development_secondary.availability_zone}"
    "rds_mysql" = "${module.development_db.rds_mysql_host}"
  }
  availability_zone = "${aws_subnet.development_secondary.availability_zone}"
  subnet_id = "${aws_subnet.development_secondary.id}"
}

module "development_haproxy_instance_primary_az" {
  source = "../modules/pressr_instance"
  ami_id = "${var.ami_id}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.development_haproxy.id}"]
  instance_count = "${var.haproxy_instance_count}"
  root_size = "${var.root_disk_size}"
  instance_type = "${var.instance_type}"
  tags = {
    "role" = "haproxy",
    "env" = "${var.environment}"
    "availability_zone" = "${aws_subnet.development_primary.availability_zone}"
  }
  availability_zone = "${aws_subnet.development_primary.availability_zone}"
  subnet_id = "${aws_subnet.development_primary.id}"
}

module "development_haproxy_instance_secondary_az" {
  source = "../modules/pressr_instance"
  ami_id = "${var.ami_id}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.development_haproxy.id}"]
  instance_count = "${var.haproxy_instance_count}"
  root_size = "${var.root_disk_size}"
  instance_type = "${var.instance_type}"
  tags = {
    "role" = "haproxy",
    "env" = "${var.environment}"
    "availability_zone" = "${aws_subnet.development_secondary.availability_zone}"
  }
  availability_zone = "${aws_subnet.development_secondary.availability_zone}"
  subnet_id = "${aws_subnet.development_secondary.id}"
}

module "development_consul_instance_primary_az" {
  source = "../modules/pressr_instance"
  ami_id = "${var.ami_id}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.development_consul.id}"]
  instance_count = "${var.consul_instance_count}"
  root_size = "${var.root_disk_size}"
  instance_type = "${var.instance_type}"
  tags = {
    "role" = "consul",
    "env" = "${var.environment}"
    "availability_zone" = "${aws_subnet.development_primary.availability_zone}"
  }
  availability_zone = "${aws_subnet.development_primary.availability_zone}"
  subnet_id = "${aws_subnet.development_primary.id}"
}

module "development_consul_instance_secondary_az" {
  source = "../modules/pressr_instance"
  ami_id = "${var.ami_id}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.development_consul.id}"]
  instance_count = "${var.consul_instance_count}"
  root_size = "${var.root_disk_size}"
  instance_type = "${var.instance_type}"
  tags = {
    "role" = "consul",
    "env" = "${var.environment}"
    "availability_zone" = "${aws_subnet.development_secondary.availability_zone}"
  }
  availability_zone = "${aws_subnet.development_secondary.availability_zone}"
  subnet_id = "${aws_subnet.development_secondary.id}"
}
