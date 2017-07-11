resource "aws_ecs_service" "onkyo-store-service" {
  name                               = "${var.service_name}"
  cluster                            = "${var.cluster_name}"
  task_definition                    = "${var.task_definition_arn}"

  desired_count                      = "${var.desired_count}"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100
  iam_role                           = "${var.iam_role}"
  depends_on                         = ["aws_iam_role_policy.ecs_service_role_policy"]

  placement_strategy {
    type                             = "spread"
    field                            = "instanceId"
  }

  placement_strategy {
    type                             = "spread"
    field                            = "attribute:ecs.availability-zone"
  }
/*
  placement_constraints {
    type                             = "distinctInstance"
  }
*/
  load_balancer {
    target_group_arn                 = "${var.target_group_arn}"
    container_name                   = "onkyo-store-task-definition-${var.environment}"#{}${var.service_name}
    container_port                   = "${var.container_port}"
  }
}

# ecs service policy 
resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name     = "ecs-service-role-policy"
    policy   = "${file("policies/ecs-service-role-policy.json")}"
    role     = "${var.iam_role}"
}