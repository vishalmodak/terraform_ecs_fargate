output "kafka_lb_dns" {
  value = "${aws_alb.kafka.dns_name}"
}

# output "kafkaui_lb_dns" {
#   value = "${aws_alb.kafka_ui.dns_name}"
# }

# output "postgres_lb_dns" {
#   value = "${module.postgres_service.service_lb_dns}"
# }

# output "transitioner_lb_dns" {
#   value = "${module.transitioner_service.service_lb_dns}"
# }
#
# output "delchecker_lb_dns" {
#   value = "${module.delchecker_service.service_lb_dns}"
# }

# output "hydrator_lb_dns" {
#   value = "${module.hydrator_service.service_lb_dns}"
# }

output "hydrator_lb_dns" {
  value = "${aws_alb.hydrator.dns_name}"
}

# output "persister_lb_dns" {
#   value = "${module.persister_service.service_lb_dns}"
# }
