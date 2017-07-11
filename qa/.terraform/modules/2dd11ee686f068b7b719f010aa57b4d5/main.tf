resource "aws_ecs_task_definition" "onkyo_store_service" {
  family                = "${var.family}"
  container_definitions = "${file("task-definitions/onkyo_store_service.json")}"
}