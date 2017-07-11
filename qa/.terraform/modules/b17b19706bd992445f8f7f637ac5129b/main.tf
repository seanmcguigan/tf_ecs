resource "aws_ecs_cluster" "onkyo-store" {
  name = "${var.name}"
}
