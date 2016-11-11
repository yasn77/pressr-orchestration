data "aws_availability_zones" "available" {}

resource "aws_vpc" "default" {
  cidr_block = "${var.cidr_block}"
  tags {
        Name = "${format("%s_vpc", var.resource_prefix)}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
        Name = "${format("%s_gateway", var.resource_prefix)}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "primary" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.primary_subnet}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags {
        Name = "${format("%s_subnet", var.resource_prefix)}"
  }
}

resource "aws_subnet" "secondary" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.secondary_subnet}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags {
        Name = "${format("%s_subnet", var.resource_prefix)}"
  }
}
