output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

# output "private_subnet_ids" {
#   value = ["${aws_subnet.private_subnet.*.id}"]
# }

output "public_subnet_ids" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "security_group_id" {
  value = "${aws_security_group.foo.id}"
}

# output "kafka_nlb_name" {
#   value = "${aws_alb.kafka.name}"
# }
