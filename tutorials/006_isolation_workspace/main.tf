terraform {
  required_version = ">=0.12.0"
  # backend "s3" {
  #   key = "workspace-example/terraform.tfstate"
  # }
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# ## define the s3 bucket
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "kashi-terraform-state"
#
#   ## prevent accidental deletion of this bucket
#   # lifecycle {
#   #   prevent_destroy = true
#   # }
#   force_destroy = true
#
#   ## enable versioning
#   versioning {
#     enabled = true
#   }
#
#   ## enable server-side encryption by default
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# ## define DynamoDB
# resource "aws_dynamodb_table" "terraform_table" {
#   name         = "kashi-terraform-state-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

resource "aws_instance" "example" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.example1.id]

  tags = {
    Name = "terraform-example"
  }

  user_data = <<-EOF
  #!/bin/bash
  echo "Hello, Kashi" > index.html
  nohup busybox httpd -f -p ${var.server_port} &
  EOF
}

resource "aws_security_group" "example1" {
  name = "terraform-example1-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ## config for VM
# resource "aws_launch_configuration" "example" {
#   image_id        = "ami-0c55b159cbfafe1f0"
#   instance_type   = "t2.micro"
#   security_groups = [aws_security_group.example.id]
#
#   user_data = <<-EOF
#   #!/bin/bash
#   echo "Hello, Kashi" > index.html
#   nohup busybox httpd -f -p ${var.server_port} &
#   EOF
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
# ## security group on port 8080
# resource "aws_security_group" "example" {
#   name = "terraform-example-sg"
#
#   ingress {
#     from_port   = var.server_port
#     to_port     = var.server_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# ## config for cluster
# resource "aws_autoscaling_group" "example" {
#   launch_configuration = aws_launch_configuration.example.name
#   vpc_zone_identifier  = data.aws_subnet_ids.default.ids
#
#   target_group_arns = [aws_lb_target_group.asg.arn]
#   health_check_type = "ELB"
#
#   min_size = 2
#   max_size = 10
#
#   tag {
#     key                 = "Name"
#     value               = "terraform-asg-example"
#     propagate_at_launch = true
#   }
# }
#
#
# ## Define the loadbalacer
# resource "aws_lb" "example" {
#   name               = "terraform-asg-example"
#   load_balancer_type = "application"
#   subnets            = data.aws_subnet_ids.default.ids
#   security_groups    = [aws_security_group.alb.id]
# }
#
# ## Define the listener
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.example.arn
#   port              = 80
#   protocol          = "HTTP"
#
#   default_action {
#     type = "fixed-response"
#
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "404: Kashi doesn't server you"
#       status_code  = 404
#     }
#   }
# }
#
# ## security group to listen on 80
# resource "aws_security_group" "alb" {
#   name = "terraform-example-alb"
#
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# ## define target group
# resource "aws_lb_target_group" "asg" {
#   name     = "terraform-asg-example"
#   port     = var.server_port
#   protocol = "HTTP"
#   vpc_id   = data.aws_vpc.default.id
#
#   health_check {
#     path                = "/"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 15
#     timeout             = 3
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }
#
# ## Define listener rules
# resource "aws_lb_listener_rule" "asg" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 100
#
#   condition {
#     path_pattern {
#       values = ["*"]
#     }
#   }
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.asg.arn
#   }
# }
