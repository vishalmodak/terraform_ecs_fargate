/*====
ECR repository to store our Docker images for services
======*/
resource "aws_ecr_repository" "hydrator" {
  name = "${var.hydrator_repo}"
}

resource "aws_ecr_repository" "transitioner" {
  name = "${var.transitioner_repo}"
}

resource "aws_ecr_repository" "persister" {
  name = "${var.persister_repo}"
}

resource "aws_ecr_repository" "postgres" {
  name = "${var.postgres_repo}"
}
