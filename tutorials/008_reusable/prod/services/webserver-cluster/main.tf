provider "aws" {
  version = "~> 2.0"
  region  = "us-east-2"
}

module "webserver_cluster" {
  # source = "../../../modules/services/webserver-cluster"
  source = "git::https://git@github.com/kashmatic/terraform-test-module.git//modules/services/webserver-cluster?ref=tags/1.0.0"

  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "kashi-terraform-state"
  db_remote_state_key    = "prod/services/data-stores/terraform.tfstate"

  instance_type = "m4.large"
  min_size      = 2
  max_size      = 10
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}
