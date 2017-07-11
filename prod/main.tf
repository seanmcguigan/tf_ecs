provider "aws" {
  region  = "${var.REGION}"
  profile = "${var.PROFILE}"
}

variable "ENV" {}
variable "PRODUCT" {}
variable "TEAM" {}
variable "SSL_CERT" {}
variable "PROFILE" {}
variable "REGION" {}

module "vpc" {
  source          = "../modules/vpc"
  name            = "${var.PRODUCT}-ecs-${var.ENV}-vpc"
  cidr            = "10.23.0.0/16"
  private_subnets = "10.23.1.0/24,10.23.2.0/24"
  public_subnets  = "10.23.4.0/24,10.23.5.0/24"
  azs             = "eu-west-1a,eu-west-1b"
}

module "sg_app" {
  source                 = "../modules/sg_app"
  security_group_name    = "sg_app"
  vpc_id                 = "${module.vpc.vpc_id}"
  source_cidr_block      = "0.0.0.0/0"
  bastion_security_group = "${module.sg_bastion.security_group_id}"
  elb_security_group     = "${module.sg_alb.security_group_id}"
  tags                   = "application security group ${var.ENV} - ${var.PRODUCT}"
}

module "sg_alb" {
  source              = "../modules/sg_alb"
  security_group_name = "sg_alb"
  vpc_id              = "${module.vpc.vpc_id}"
  source_cidr_block   = "0.0.0.0/0"
  tags                = "alb security group ${var.ENV} - ${var.PRODUCT}"
}

module "sg_bastion" {
  source              = "../modules/sg_bastion"
  security_group_name = "sg_bastion"
  vpc_id              = "${module.vpc.vpc_id}"
  source_cidr_block   = "0.0.0.0/0"
  restricted_access   = "84.233.151.236/32"
  tags                = "bastion security group ${var.ENV} - ${var.PRODUCT}"
}

module "bastion_server" {
  source                      = "../modules/bastion_server"
  ami                         = "ami-9398d3e0"                           
  count                       = "1"
  tags                        = "${var.PRODUCT}-bastion-ecs-${var.ENV}"
  team                        = "${var.TEAM}"
  instance_type               = "t2.small"
  key_name                    = "tf_${var.PRODUCT}"
  security_groups             = "${module.sg_bastion.security_group_id}"
  subnet_id                   = "${module.vpc.public_subnets}"
  associate_public_ip_address = "true"
  source_dest_check           = "false"
}

module "dns" {
  source  = "../modules/dns"
  zone_id = "Z1CS2DGR5B4GQB"
  name    = "${var.PRODUCT}"
  type    = "CNAME"
  ttl     = "300"
  records = "${module.alb.alb_dns}"
}

module "alb" {
  source                      = "../modules/alb"
  name                        = "onkyo-alb-${var.ENV}"
  security_groups             = "${module.sg_alb.security_group_id}"
  target_port                 = "80"
  target_protocol             = "HTTP"
  listening_port              = 80
  listening_protocol          = "HTTP"
  ssl_certificate_id          = "${var.SSL_CERT}"
  healthy_threshold           = 5
  unhealthy_threshold         = 5
  interval                    = "15"
  subnets                     = "${module.vpc.public_subnets}"
  idle_timeout                = 120 # The time in seconds that the connection is allowed to be idle. Default: 60.
  tag_name                    = "${var.PRODUCT} alb ${var.ENV}"
  team                        = "${var.TEAM}"
  vpc                         = "${module.vpc.vpc_id}"
}

module "cloudwatch" {
    source               = "../modules/cloudwatch"
    agents_scale_up      = "${module.autoscaling_policy.scale-up-ec2-cluster}"
    agents_scale_down    = "${module.autoscaling_policy.scale-down-ec2-cluster}"
    cluster_name         = "${module.autoscaling_groups.cluster_name}"
    environment          = "${var.ENV}"
}

module "launch_configurations" {
  source          = "../modules/launch_configurations"
  name            = "${var.PRODUCT}-cluster-ec2-launch-configuration"
  environment     = "${var.ENV}"
  instance_type   = "t2.medium"
  ami             = "ami-5ae4f83c"
  key_name        = "tf_onkyo-store"
  security_groups = "${module.sg_app.security_group_id}"
}
 
module "autoscaling_groups" {
  source                    = "../modules/autoscaling_groups"
  vpc_zone_identifier       = "${module.vpc.private_subnets}"
  launch_configuration      = "${module.launch_configurations.ecs}"
  cluster_name              = "onkyo-ecs-cluster-${var.ENV}"
  max_size                  = 6
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  enabled_metrics           = "GroupTerminatingInstances,GroupMaxSize,GroupDesiredCapacity,GroupPendingInstances,GroupInServiceInstances,GroupMinSize,GroupTotalInstances"
}

module "autoscaling_policy" {
  source                 = "../modules/autoscaling_policy"
  autoscaling_group_name = "${module.autoscaling_groups.cluster_name}"
}

module "ecs_cluster" {
  source = "../modules/ecs_cluster"
  name   = "onkyo-ecs-cluster-${var.ENV}"
}

module "ecs_task_definition" {
  source = "../modules/ecs_task_definition"
  family = "${var.PRODUCT}-task-definition-${var.ENV}"
}

module "ecs_service" {
  source           = "../modules/ecs_service"
  iam_role         = "${module.launch_configurations.iam_role}"
  service_name     = "${var.PRODUCT}-ecs-service-${var.ENV}"
  cluster_name     = "${module.ecs_cluster.aws_ecs_cluster}"
  desired_count    = "2"
  target_group_arn = "${module.alb.aws_alb_target_group}"
  container_name   = "${var.PRODUCT}-task-definition-${var.ENV}"
  container_port   = "80"
  environment      = "${var.ENV}"
  task_definition_arn = "${module.ecs_task_definition.task_definition_arn}"
}

output "vpc id" {
  value = "${module.vpc.vpc_id}"
}

output "alb dns name" {
  value = "${module.alb.alb_dns}"
}

output "bastion public ip address" {
  value = "${module.bastion_server.bastion_public_ip}"
}