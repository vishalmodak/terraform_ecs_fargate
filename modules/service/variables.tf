variable "environment" {
  description = "Dev/Staging/Prod"
}

/*
    Networking variables
*/
variable "vpc_id" {
  description = "Main VPC ID"
}

variable "subnet_ids" {
  type        = list
  description = "Subnet IDs"
}

variable "security_group_id" {
  description = "Security group ID"
}

/*
    ECS variables
*/

variable "ecs_cluster_id" {
  description = "ECS cluster ID"
}

variable "ecs_task_family" {
  description = "Name for the ECS Task definition family "
}

variable "ecs_task_revision" {
  description = "ECS Task revision number"
  default     = "latest"
}

variable "task_definition_template_path" {
  description = "Task definiton template file"
}

variable "template_vars" {
  type        = "map"
  description = "list variables & values based on task definition JSON"
}

variable "execution_role_arn" {
  description = "Task Execution Role ARN"
}

variable "ecs_task_cpu" {
  description = "ECS Task CPU Units"
}

variable "ecs_task_memory" {
  description = "ECS Task Memory Units"
}

variable "instance_count" {
  description = "Desired number of service instances"
}
/*
  Load Balancer variables
*/
variable "container_port" {
  description = "Port exposed from Container"
}

variable "lb_port" {
  description = "Service LB listener to_port"
}

variable "lb_protocol" {
  description = "Service LB listener protocol"
  default     = "TCP"
}
