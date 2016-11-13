resource "aws_vpc" "pressr_production" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true
  tags {
        Name = "${format("%s_vpc", var.resource_prefix)}"
  }
}

resource "aws_internet_gateway" "pressr_production" {
  vpc_id = "${aws_vpc.pressr_production.id}"
  tags {
        Name = "${format("%s_gateway", var.resource_prefix)}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.pressr_production.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.pressr_production.id}"
}

resource "aws_subnet" "production_primary" {
  vpc_id                  = "${aws_vpc.pressr_production.id}"
  cidr_block              = "${var.primary_subnet}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags {
        Name = "${format("%s_subnet", var.resource_prefix)}"
  }
}

resource "aws_subnet" "production_secondary" {
  vpc_id                  = "${aws_vpc.pressr_production.id}"
  cidr_block              = "${var.secondary_subnet}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags {
        Name = "${format("%s_subnet", var.resource_prefix)}"
  }
}
