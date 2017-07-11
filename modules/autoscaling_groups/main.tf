resource "aws_autoscaling_group" "ecs" {
    name                      = "${var.cluster_name}"
    vpc_zone_identifier       = ["${split(",", var.vpc_zone_identifier)}"]
    max_size                  = "${var.max_size}"
    min_size                  = "${var.min_size}"
    health_check_grace_period = "${var.health_check_grace_period}"
    health_check_type         = "${var.health_check_type}"
    force_delete              = "${var.force_delete}"
    launch_configuration      = "${var.launch_configuration}"
    enabled_metrics           = ["${split(",",var.enabled_metrics)}"]
  
    tag {
      key                 = "Name"
      value               = "ecs-autoscaling-instance-${var.cluster_name}"
      propagate_at_launch = true
  }
}