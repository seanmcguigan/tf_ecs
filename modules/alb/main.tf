resource "aws_alb" "onkyo-store" {
  name            = "${var.name}"
  internal        = false
  security_groups = ["${var.security_groups}"]
  subnets         = ["${split(",", var.subnets)}"]
  enable_deletion_protection = false
/*
  access_logs {
    bucket        = "${aws_s3_bucket.logs.bucket}"
    prefix        = "${var.project}"
  }
*/
  tags {
    Name          = "${var.tag_name}-alb"
    team          = "${var.team}"
  }
}

# Target containers are regestered by the ECS service
resource "aws_alb_target_group" "onkyo-store" {
  name     = "${var.name}-target-group"
  port     = "${var.target_port}"
  protocol = "${var.target_protocol}"
  vpc_id   = "${var.vpc}"
  depends_on = ["aws_alb.onkyo-store"]

  stickiness {
    type   = "lb_cookie"
  }
  health_check {
    path                = "/"
    healthy_threshold   = "${var.healthy_threshold}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
    interval            = "${var.interval}"
  }
  tags {
    Name = "${var.tag_name}-group"
  }
}


resource "aws_alb_listener" "http" {
   load_balancer_arn  = "${aws_alb.onkyo-store.arn}"
   port               = "${var.listening_port}"
   protocol           = "${var.listening_protocol}"
   default_action {
     target_group_arn = "${aws_alb_target_group.onkyo-store.arn}"
     type = "forward"
   }
}


/*
resource "aws_alb_listener" "https" {
   load_balancer_arn  = "${aws_alb.onkyo-store.arn}"
   port               = "${var.listening_port}"
   protocol           = "${var.listening_protocol}"
   ssl_policy         = "ALBSecurityPolicy-2015-05"
   certificate_arn    = "${var.ssl_certificate_id}"

   default_action {
     target_group_arn = "${aws_alb_target_group.onkyo-store.arn}"
     type = "forward"
   }
}

resource "aws_alb_listener_rule" "host_based_routing" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.static.arn}"
  }

  condition {
    field  = "host-header"
    values = ["my-service.*.terraform.io"]
  }
}

resource "aws_alb_listener_rule" "static" {
  listener_arn = "${aws_alb_listener.http.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.onkyo-store.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/GB/home/*"]
  }
}
*/
