resource "aws_security_group_rule" "kafka" {
  type      = "ingress"
  from_port = "9092"
  to_port   = "9092"
  protocol  = "TCP"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${module.networking.security_group_id}"
  description       = "kafka"

  depends_on = ["module.networking.security_group_id"]
}

resource "aws_alb_target_group" "kafka_target_group" {
  name        = "kafka-ip-routing-group"
  port        = 9092
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = "${module.networking.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
  depends_on = ["module.networking.vpc_id"]
}

resource "aws_alb" "kafka" {
  name               = "kafka-balancer"
  internal           = false
  load_balancer_type = "network"
  subnets            = flatten(["${module.networking.public_subnet_ids}"])
  //Security groups are not supported for NLBs
  # security_groups    = ["${module.networking.security_group_id}"]

  tags = {
    Name        = "${var.environment}"
    Environment = "${var.environment}"
  }
  depends_on = ["module.networking.public_subnet_ids"]
}

resource "aws_alb_listener" "kafka" {
  load_balancer_arn = "${aws_alb.kafka.arn}"
  port              = "9092"
  protocol          = "TCP"
  depends_on        = ["aws_alb_target_group.kafka_target_group"]

  default_action {
    target_group_arn = "${aws_alb_target_group.kafka_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_cloudwatch_log_group" "kafka" {
  name = "/ecs/kafka"

  tags = {
    Environment = "${var.environment}"
    Application = "Kafka"
  }
}

resource "aws_cloudwatch_log_group" "zookeeper" {
  name = "/ecs/zookeeper"

  tags = {
    Environment = "${var.environment}"
    Application = "Zookeeper"
  }
}

data "template_file" "kafka_template" {
  template = "${file("${path.module}/task-definitions/kafka-stack.json")}"
  vars = {
    kafka_lb_dns    = "${aws_alb.kafka.dns_name}"
    zk_log_group    = "${aws_cloudwatch_log_group.zookeeper.name}"
    kafka_log_group = "${aws_cloudwatch_log_group.kafka.name}"
  }
  depends_on = ["aws_alb.kafka", "aws_cloudwatch_log_group.zookeeper", "aws_cloudwatch_log_group.kafka"]
}

resource "aws_ecs_task_definition" "kafka" {
  family                   = "kafka-stack"
  container_definitions    = "${data.template_file.kafka_template.rendered}"
  execution_role_arn       = "${module.iam.role_arn}"
  task_role_arn            = "${module.iam.role_arn}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_service" "kafka" {
  name            = "${aws_ecs_task_definition.kafka.family}"
  task_definition = "${aws_ecs_task_definition.kafka.family}:${max("${aws_ecs_task_definition.kafka.revision}", "${aws_ecs_task_definition.kafka.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.cluster.id}"

  network_configuration {
    security_groups  = ["${module.networking.security_group_id}"]
    subnets          = flatten(["${module.networking.public_subnet_ids}"])
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.kafka_target_group.arn}"
    container_name   = "kafka"
    container_port   = "9092"
  }

  depends_on = [
    "aws_ecs_task_definition.kafka",
    "aws_alb_target_group.kafka_target_group",
    "module.networking.public_subnet_ids"
  ]

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}
