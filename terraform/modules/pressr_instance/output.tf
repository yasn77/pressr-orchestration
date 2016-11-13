output "id_list" {
  value = ["${aws_instance.pressr.*.id}"]
}
