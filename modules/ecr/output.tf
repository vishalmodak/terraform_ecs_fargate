output "hydrator_service_repo_url" {
  value = "${aws_ecr_repository.hydrator.repository_url}"
}

output "transitioner_service_repo_url" {
  value = "${aws_ecr_repository.transitioner.repository_url}"
}

output "persister_service_repo_url" {
  value = "${aws_ecr_repository.persister.repository_url}"
}

output "postgres_service_repo_url" {
  value = "${aws_ecr_repository.postgres.repository_url}"
}
