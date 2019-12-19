# resource "aws_alb_target_group" "kafka_ui_target_group" {
#   name        = "kafka-ui-ip-routing-group"
#   port        = 8000
#   protocol    = "TCP"
#   target_type = "ip"
#   vpc_id      = "${module.networking.vpc_id}"
#
#   lifecycle {
#     create_before_destroy = true
#   }
#   depends_on = ["module.networking.vpc_id"]
# }
#
# resource "aws_alb" "kafka_ui" {
#   name               = "kafka-ui-balancer"
#   internal           = false
#   load_balancer_type = "network"
#   subnets            = flatten(["${module.networking.public_subnet_ids}"])
#   # security_groups    = ["${module.networking.security_group_id}"]
#
#   tags = {
#     Name        = "${var.environment}"
#     Environment = "${var.environment}"
#   }
#   depends_on = ["module.networking.public_subnet_ids"]
# }
#
# resource "aws_alb_listener" "kafka_ui" {
#   load_balancer_arn = "${aws_alb.kafka_ui.arn}"
#   port              = "8000"
#   protocol          = "TCP"
#   depends_on        = ["aws_alb_target_group.kafka_ui_target_group"]
#
#   default_action {
#     target_group_arn = "${aws_alb_target_group.kafka_ui_target_group.arn}"
#     type             = "forward"
#   }
# }
#
# resource "aws_security_group_rule" "kafka_proxy_rule" {
#   type      = "ingress"
#   from_port = "8082"
#   to_port   = "8082"
#   protocol  = "TCP"
#   # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = "${module.networking.security_group_id}"
#   description       = "kafka rest proxy"
#
#   depends_on = ["module.networking.security_group_id"]
# }
#
# resource "aws_security_group_rule" "kafka_ui_rule" {
#   type      = "ingress"
#   from_port = "8000"
#   to_port   = "8000"
#   protocol  = "TCP"
#   # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = "${module.networking.security_group_id}"
#   description       = "kafka ui"
#
#   depends_on = ["module.networking.security_group_id"]
# }
#
# resource "aws_cloudwatch_log_group" "kafka_ui" {
#   name = "/ecs/kafkaui"
#
#   tags = {
#     Environment = "${var.environment}"
#     Application = "Kafka Topics UI"
#   }
# }
#
# resource "aws_cloudwatch_log_group" "rest_proxy" {
#   name = "/ecs/kafkarestproxy"
#
#   tags = {
#     Environment = "${var.environment}"
#     Application = "Kafka Rest Proxy"
#   }
# }
#
# data "template_file" "kafka_ui_template" {
#   template = "${file("${path.module}/task-definitions/kafka-ui.json")}"
#   vars = {
#     kafka_lb_dns    = "${aws_alb.kafka.dns_name}"
#     proxy_log_group = "${aws_cloudwatch_log_group.rest_proxy.name}"
#     ui_log_group    = "${aws_cloudwatch_log_group.kafka_ui.name}"
#   }
#   depends_on = ["aws_alb.kafka", "aws_alb.kafka_ui", "aws_cloudwatch_log_group.kafka_ui", "aws_cloudwatch_log_group.rest_proxy"]
# }
#
# resource "aws_ecs_task_definition" "kafka_ui" {
#   family                   = "kafka_ui"
#   container_definitions    = "${data.template_file.kafka_ui_template.rendered}"
#   execution_role_arn       = "${module.iam.role_arn}"
#   task_role_arn            = "${module.iam.role_arn}"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = 1024
#   memory                   = 2048
#   lifecycle {
#     ignore_changes = all
#   }
# }
#
# resource "aws_ecs_service" "kafka_ui" {
#   name            = "${aws_ecs_task_definition.kafka_ui.family}"
#   task_definition = "${aws_ecs_task_definition.kafka_ui.family}:${max("${aws_ecs_task_definition.kafka_ui.revision}", "${aws_ecs_task_definition.kafka_ui.revision}")}"
#   desired_count   = 1
#   launch_type     = "FARGATE"
#   cluster         = "${aws_ecs_cluster.cluster.id}"
#
#   network_configuration {
#     security_groups  = ["${module.networking.security_group_id}"]
#     subnets          = flatten(["${module.networking.public_subnet_ids}"])
#     assign_public_ip = true
#   }
#
#   load_balancer {
#     target_group_arn = "${aws_alb_target_group.kafka_ui_target_group.arn}"
#     container_name   = "kafka-ui"
#     container_port   = "8000"
#   }
#
#   depends_on = ["aws_ecs_service.kafka", "aws_alb_target_group.kafka_ui_target_group", "module.networking.public_subnet_ids"]
#   lifecycle {
#     ignore_changes = ["task_definition"]
#   }
# }
