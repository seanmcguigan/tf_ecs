terraform {
  backend "s3" {
    bucket = "7digital-onkyo-store-ecs-tfstate"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
  }
}