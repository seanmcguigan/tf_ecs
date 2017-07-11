output "alb_dns" {
  value = "${aws_alb.onkyo-store.dns_name}"
}

output "alb_id" {
  value = "${aws_alb.onkyo-store.id}"
}

output "aws_alb_target_group" { 
  value =  "${aws_alb_target_group.onkyo-store.id}"
}