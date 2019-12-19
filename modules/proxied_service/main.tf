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

  proxy_configuration {
    type           = "APPMESH"
    container_name = "${var.ecs_task_family}_proxy"
    properties = {
      IgnoredUID       = "1337"                  # this is required to ignore envoy internal traffic and must match the user specified in task defintion JSON
      AppPorts         = "${var.container_port}" # port on which the application container listens
      ProxyIngressPort = "15000"
      ProxyEgressPort  = "15001"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254" #ignores the Amazon EC2 metadata server and the Amazon ECS task metadata endpoint.
    }
  }

  lifecycle {
    # Avoid triggering revisions of task definitions when unchanged
    ignore_changes = all
    # # make sure Terraform does not unregister the task definition
    # prevent_destroy = true
  }
}

resource "aws_service_discovery_service" "service" {
  name = "${var.ecs_task_family}"
  dns_config {
    namespace_id = "${var.discovery_namespace_id}"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }

}

resource "aws_ecs_service" "service" {
  name            = "${var.ecs_task_family}"
  task_definition = "${var.ecs_task_family}:${var.ecs_task_revision == "latest" ? max(aws_ecs_task_definition.service.revision, aws_ecs_task_definition.service.revision) : var.ecs_task_revision}"
  desired_count   = "${var.instance_count}"
  launch_type     = "FARGATE"
  cluster         = "${var.ecs_cluster_id}"

  network_configuration {
    security_groups  = ["${var.security_group_id}"]
    subnets          = flatten(["${var.subnet_ids}"])
    assign_public_ip = true
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.service.arn}"
  }

  depends_on = ["aws_service_discovery_service.service", "aws_ecs_task_definition.service"]

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}
