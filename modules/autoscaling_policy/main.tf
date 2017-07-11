# Scaling Policies
resource "aws_autoscaling_policy" "scale-down-ec2-cluster" {
  name                   = "scale-down-ec2-cluster"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = "${var.autoscaling_group_name}"
}

resource "aws_autoscaling_policy" "scale-up-ec2-cluster" {
  name                   = "scale-up-ec2-cluster"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = "${var.autoscaling_group_name}"
}
