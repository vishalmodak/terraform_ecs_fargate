resource "aws_cloudwatch_log_group" "transitioner" {
  name = "/ecs/transitioner"

  tags = {
    Environment = "${var.environment}"
    Application = "transitioner"
  }
}

# resource "aws_cloudwatch_log_group" "hydrator" {
#   name = "/ecs/hydrator"
#
#   tags = {
#     Environment = "${var.environment}"
#     Application = "hydrator"
#   }
# }

# resource "aws_cloudwatch_log_group" "persister" {
#   name = "/ecs/persister"
#
#   tags = {
#     Environment = "${var.environment}"
#     Application = "persister"
#   }
# }
#
# resource "aws_cloudwatch_log_group" "persister_proxy" {
#   name = "/ecs/persister_proxy"
#
#   tags = {
#     Environment = "${var.environment}"
#     Application = "Persister Proxy"
#   }
# }

resource "aws_cloudwatch_log_group" "postgres" {
  name = "/ecs/postgres"

  tags = {
    Environment = "${var.environment}"
    Application = "postgres"
  }
}

resource "aws_cloudwatch_log_group" "postgres_proxy" {
  name = "/ecs/postgres_proxy"

  tags = {
    Environment = "${var.environment}"
    Application = "postgres"
  }
}

resource "aws_cloudwatch_log_group" "delchecker" {
  name = "/ecs/delchecker"

  tags = {
    Environment = "${var.environment}"
    Application = "delchecker"
  }
}

module "postgres_service" {
  source            = "../modules/proxied_service"
  environment       = "${var.environment}"
  vpc_id            = "${module.networking.vpc_id}"
  subnet_ids        = "${module.networking.public_subnet_ids}"
  security_group_id = "${module.networking.security_group_id}"

  ecs_cluster_id                = "${aws_ecs_cluster.cluster.id}"
  ecs_task_family               = "postgres"
  instance_count                = 1
  execution_role_arn            = "${module.iam.role_arn}"
  task_definition_template_path = "task-definitions/postgres.json"
  template_vars = {
    image           = "142608611295.dkr.ecr.us-east-2.amazonaws.com/postgres"
    log_group       = "${aws_cloudwatch_log_group.postgres.name}"
    proxy_log_group = "${aws_cloudwatch_log_group.postgres_proxy.name}"
  }
  ecs_task_cpu           = 1024
  ecs_task_memory        = 2048
  container_port         = 5432
  lb_port                = 5432
  discovery_namespace_id = "${aws_service_discovery_private_dns_namespace.foo.id}"
}
