# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "development_elb" {
  name = "${format("%s_elb_security_group", var.resource_prefix)}"
  description = "PressR ELB"
  vpc_id      = "${aws_vpc.pressr_development.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "development_haproxy" {
  name = "${format("%s_haproxy_security_group", var.resource_prefix)}"
  description = "PressR haproxy"
  vpc_id      = "${aws_vpc.pressr_development.id}"

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "development_consul" {
  name = "${format("%s_consul_security_group", var.resource_prefix)}"
  description = "PressR consul"
  vpc_id      = "${aws_vpc.pressr_development.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 8400
    to_port     = 8400
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "development_db" {
  name = "${format("%s_db_security_group", var.resource_prefix)}"
  description = "Default PressR DB security group"
  vpc_id      = "${aws_vpc.pressr_development.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "development_app" {
  name = "${format("%s_default_security_group", var.resource_prefix)}"
  description = "Default PressR security group"
  vpc_id      = "${aws_vpc.pressr_development.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 32768
    to_port     = 60999
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
