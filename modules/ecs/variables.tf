variable "environment" {
  description = "The environment"
  default     = "foo-dev"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}
