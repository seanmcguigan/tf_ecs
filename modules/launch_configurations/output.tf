output "ecs" {
  value = "${aws_launch_configuration.ecs.id}"
}

output "iam_role" {
  value = "${aws_iam_role.ecs_role.id}"
}