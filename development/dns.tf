# resource "aws_route53_zone" "private" {
#   name = "foo.local"
#
#   vpc {
#     vpc_id = "${module.networking.vpc_id}"
#   }
#
#   tags = {
#     Environment = "${var.environment}"
#   }
# }
#
