resource "aws_appmesh_mesh" "foo" {
  name = "foo"

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
}

resource "aws_service_discovery_private_dns_namespace" "foo" {
  name = "foo"
  vpc  = "${module.networking.vpc_id}"
}
