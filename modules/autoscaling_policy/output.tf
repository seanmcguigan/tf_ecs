  
output "scale-up-ec2-cluster" {
   value = "${aws_autoscaling_policy.scale-up-ec2-cluster.arn}"
}
output "scale-down-ec2-cluster" {
   value = "${aws_autoscaling_policy.scale-down-ec2-cluster.arn}"
}