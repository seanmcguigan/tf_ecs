# Launch Configuration
resource "aws_launch_configuration" "ecs" {
    name                 = "${var.name}-${var.environment}"
 #   name_prefix          = "aws_launch_configuration_ecs"
    image_id             = "${var.ami}"
    instance_type        = "${var.instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.ecs_inst_profile.id}"
    user_data            = "${file("cluster_name.sh")}"
    key_name             = "${var.key_name}"
    security_groups      = ["${var.security_groups}"]
    lifecycle {
        create_before_destroy = true
    }
}


### IAM ###

# ecs iam role
resource "aws_iam_role" "ecs_role" {
    name               = "ecs_role-${var.environment}"
    assume_role_policy = "${file("policies/ecs-role-${var.environment}.json")}"
}

# ec2 instance policy
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
    name     = "ecs_instance_role_policy_${var.environment}"
    policy   = "${file("policies/ecs-instance-role-policy.json")}"
    role     = "${aws_iam_role.ecs_role.id}"
}
# associate with role
resource "aws_iam_instance_profile" "ecs_inst_profile" {
    name  = "ecs_inst_profile_${var.environment}"
    role  = "${aws_iam_role.ecs_role.name}"
}