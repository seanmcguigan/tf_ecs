resource "aws_cloudwatch_metric_alarm" "memory-reservation-below-18" {
  alarm_name          = "ECS-${var.environment}-cluster-memory-reservation-below-18"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1" #consecutive period(s)
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "180" #period - (Required) 
  #The period in seconds over which the specified statistic is applied.
  statistic           = "Average"
  threshold           = "18" #threshold - (Required) The value against
  # which the specified statistic is compared.
  dimensions {
    ClusterName = "${var.cluster_name}" 
  }
  alarm_description   = "This metric monitors ECS memory reservation and scales in"
  alarm_actions       = ["${var.agents_scale_down}"]
}

resource "aws_cloudwatch_metric_alarm" "memory-reservation-above-70" {
  alarm_name          = "ECS-${var.environment}-cluster-memory-reservation-above-70"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "70"
  dimensions {
    ClusterName = "${var.cluster_name}" 
  }
  alarm_description   = "This metric monitors ECS memory reservation and scales out"
  alarm_actions       = ["${var.agents_scale_up}"]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 12
  min_capacity       = 2
  resource_id        = "service/onkyo-ecs-cluster-${var.environment}/onkyo-store-ecs-service-${var.environment}"
  role_arn           = "arn:aws:iam::469564823659:role/ecsAutoscaleRole"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "service_down" {
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Average"
  name                    = "service-down-${var.environment}" # Grrr!! https://github.com/hashicorp/terraform/issues/14302
  resource_id             = "service/onkyo-ecs-cluster-${var.environment}/onkyo-store-ecs-service-${var.environment}"
  scalable_dimension      = "ecs:service:DesiredCount"
  service_namespace       = "ecs"

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }

  depends_on = ["aws_appautoscaling_target.ecs_target"]
}

resource "aws_appautoscaling_policy" "service_up" {
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 60
  metric_aggregation_type   = "Average"
  name                      = "service-up-${var.environment}" # Grrr again!! https://github.com/hashicorp/terraform/issues/14302
  resource_id               = "service/onkyo-ecs-cluster-${var.environment}/onkyo-store-ecs-service-${var.environment}"
  scalable_dimension        = "ecs:service:DesiredCount"
  service_namespace         = "ecs"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment = 1
  }
  depends_on = ["aws_appautoscaling_target.ecs_target"]
}

resource "aws_cloudwatch_metric_alarm" "service_up" {
  alarm_name          = "ECS-${var.environment}-service-memory-utilization-above-70"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions {
    ClusterName = "onkyo-ecs-cluster-${var.environment}"
    ServiceName = "onkyo-store-ecs-service-${var.environment}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.service_up.arn}"]
  depends_on    = ["aws_appautoscaling_policy.service_up"]
}

resource "aws_cloudwatch_metric_alarm" "service_down" {
  alarm_name          = "ECS-${var.environment}-service-memory-utilization-below-25"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "0.1"

  dimensions {
    ClusterName = "onkyo-ecs-cluster-${var.environment}"
    ServiceName = "onkyo-store-ecs-service-${var.environment}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.service_down.arn}"]
  depends_on    = ["aws_appautoscaling_policy.service_down"]
}
