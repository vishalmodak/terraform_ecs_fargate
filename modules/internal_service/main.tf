//Security group rule for Service port
resource "aws_security_group_rule" "service_rule" {
  type      = "ingress"
  from_port = "${var.lb_port}"
  to_port   = "${var.container_port}"
  protocol  = "${var.lb_protocol}"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.security_group_id}"
  description       = "${var.ecs_task_family}"

  lifecycle {
    ignore_changes = all
  }
}

data "template_file" "service_template" {
  template = "${file("${var.task_definition_template_path}")}"
  vars     = "${var.template_vars}"
}


//ECS Task defintion for service
resource "aws_ecs_task_definition" "service" {
  family                   = "${var.ecs_task_family}"
  container_definitions    = "${data.template_file.service_template.rendered}"
  execution_role_arn       = "${var.execution_role_arn}"
  task_role_arn            = "${var.execution_role_arn}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.ecs_task_cpu}"
  memory                   = "${var.ecs_task_memory}"

  lifecycle {
    # Avoid triggering revisions of task definitions when unchanged
    ignore_changes = all
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.ecs_task_family}"
  task_definition = "${var.ecs_task_family}:${max("${aws_ecs_task_definition.service.revision}", "${aws_ecs_task_definition.service.revision}")}"
  desired_count   = "${var.instance_count}"
  launch_type     = "FARGATE"
  cluster         = "${var.ecs_cluster_id}"

  network_configuration {
    security_groups  = ["${var.security_group_id}"]
    subnets          = flatten(["${var.subnet_ids}"])
    assign_public_ip = true
  }

  # load_balancer {
  #   target_group_arn = "${aws_alb_target_group.service_target_group.arn}"
  #   container_name   = "${var.ecs_task_family}"
  #   container_port   = "${var.container_port}"
  # }

  depends_on = ["aws_ecs_task_definition.service"]

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}
