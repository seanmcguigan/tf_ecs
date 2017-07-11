output "task_definition_arn" {
  value = "${aws_ecs_task_definition.onkyo_store_service.arn}"
}
