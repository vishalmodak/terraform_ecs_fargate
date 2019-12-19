#-----------------------------------
#       App Mesh Resources
#-----------------------------------

resource "aws_appmesh_virtual_router" "postgres" {
  name      = "postgres_router"
  mesh_name = "${aws_appmesh_mesh.lse.id}"

  spec {
    listener {
      port_mapping {
        port     = 8080
        protocol = "tcp"
      }
    }
  }
  depends_on = ["aws_appmesh_mesh.lse"]
}

resource "aws_appmesh_virtual_node" "postgres" {
  name      = "postgres_node"
  mesh_name = "${aws_appmesh_mesh.lse.id}"

  spec {
    backend {
      virtual_service {
        virtual_service_name = "postgres.lse"
      }
    }

    listener {
      port_mapping {
        port     = 5432 # this must match AppPorts in postgres task definition
        protocol = "tcp"
      }
    }

    service_discovery {
      aws_cloud_map {
        attributes = {
          stack = "blue"
        }
        # The name of the AWS Cloud Map service to use.
        service_name = "postgres"
        # The name of the AWS Cloud Map namespace to use.
        namespace_name = "${aws_service_discovery_private_dns_namespace.lse.name}"
      }
    }
    logging {
      access_log {
        file {
          path = "/dev/stdout"
        }
      }
    }
  }
  depends_on = ["aws_appmesh_mesh.lse", "aws_service_discovery_private_dns_namespace.lse"]
}

resource "aws_appmesh_virtual_service" "postgres" {
  name      = "postgres_service"
  mesh_name = "${aws_appmesh_mesh.lse.id}"

  spec {
    provider {
      virtual_node {
        virtual_node_name = "${aws_appmesh_virtual_node.postgres.name}"
      }
    }
  }
  depends_on = ["aws_appmesh_virtual_node.postgres", "aws_appmesh_mesh.lse"]
}

resource "aws_appmesh_route" "postgres" {
  name                = "postgres-route"
  mesh_name           = "${aws_appmesh_mesh.lse.id}"
  virtual_router_name = "${aws_appmesh_virtual_router.postgres.name}"

  spec {
    tcp_route {
      action {
        weighted_target {
          virtual_node = "${aws_appmesh_virtual_node.postgres.name}"
          weight       = 100
        }
      }
    }
  }
  depends_on = ["aws_appmesh_mesh.lse", "aws_appmesh_virtual_router.postgres", "aws_appmesh_virtual_node.postgres"]
}


# resource "aws_alb_target_group" "postgres_target_group" {
#   name        = "postgres-ip-routing-group"
#   port        = 5432
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
# resource "aws_alb" "postgres" {
#   name               = "postgres-balancer"
#   internal           = false
#   load_balancer_type = "network"
#   subnets            = flatten(["${module.networking.public_subnet_ids}"])
#
#   tags = {
#     Name        = "${var.environment}"
#     Environment = "${var.environment}"
#   }
#   depends_on = ["module.networking.public_subnet_ids"]
# }
#
# resource "aws_alb_listener" "postgres" {
#   load_balancer_arn = "${aws_alb.postgres.arn}"
#   port              = "5432"
#   protocol          = "TCP"
#   depends_on        = ["aws_alb_target_group.postgres_target_group"]
#
#   default_action {
#     target_group_arn = "${aws_alb_target_group.postgres_target_group.arn}"
#     type             = "forward"
#   }
# }
#
# resource "aws_cloudwatch_log_group" "postgres" {
#   name = "/ecs/postgres"
#
#   tags = {
#     Environment = "${var.environment}"
#     Application = "postgres"
#   }
# }
#
# data "template_file" "postgres_template" {
#   template = "${file("${path.module}/task-definitions/postgres.json")}"
#   vars = {
#     image        = "142608611295.dkr.ecr.us-east-2.amazonaws.com/postgres"
#     kafka_lb_dns = "${aws_alb.kafka.dns_name}"
#     log_group    = "${aws_cloudwatch_log_group.postgres.name}"
#   }
#   depends_on = ["aws_alb.postgres", "aws_cloudwatch_log_group.postgres"]
# }
#
# resource "aws_ecs_task_definition" "postgres" {
#   family                   = "postgres"
#   container_definitions    = "${data.template_file.postgres_template.rendered}"
#   execution_role_arn       = "${module.iam.role_arn}"
#   task_role_arn            = "${module.iam.role_arn}"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = 512
#   memory                   = 1024
#   lifecycle {
#     ignore_changes = all
#   }
# }
#
# resource "aws_ecs_service" "postgres" {
#   name            = "${aws_ecs_task_definition.postgres.family}"
#   task_definition = "${aws_ecs_task_definition.postgres.family}:${max("${aws_ecs_task_definition.postgres.revision}", "${aws_ecs_task_definition.postgres.revision}")}"
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
#     target_group_arn = "${aws_alb_target_group.postgres_target_group.arn}"
#     container_name   = "postgres"
#     container_port   = "5432"
#   }
#
#   depends_on = ["aws_alb_target_group.postgres_target_group", "module.networking.public_subnet_ids"]
#   lifecycle {
#     ignore_changes = ["task_definition"]
#   }
# }
