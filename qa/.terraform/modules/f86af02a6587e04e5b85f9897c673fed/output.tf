output "cluster_name" {
  value = "${aws_autoscaling_group.ecs.name}"
}