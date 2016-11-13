data "template_file" "cloud-init" {
  template = "${file("${path.module}/cloud-config.tpl")}"

  vars {
    role = "${var.tags["role"]}"
    env = "${var.tags["env"]}"
    availability_zone = "${var.tags["availability_zone"]}"
  }
}

resource "aws_instance" "pressr" {
  connection {
    user = "ubuntu"
  }
  count = "${var.instance_count}"
  availability_zone = "${var.availability_zone}"
  subnet_id = "${var.subnet_id}"
  user_data = "${data.template_file.cloud-init.rendered}"
  instance_type = "${var.instance_type}"
  ami = "${var.ami_id}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  tags = "${merge(map("project", "pressr"), var.tags)}"
  root_block_device {
    volume_size = "${var.root_size}"
  }
}
