resource "aws_placement_group" "main" {
  name     = var.project
  strategy = "spread"
}
resource "aws_autoscaling_group" "main" {
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  placement_group     = aws_placement_group.main.id
  vpc_zone_identifier = [aws_subnet.main.id]
  #   suspended_processes = ["ReplaceUnhealthy"]

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
  }
}

resource "aws_launch_template" "main" {
  name = var.project

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
    }
  }

  disable_api_termination = false

  iam_instance_profile {
    name = aws_iam_instance_profile.cluster.name
  }

  image_id = data.aws_ami.main.id

  instance_initiated_shutdown_behavior = "terminate"


  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.main.id]
    delete_on_termination       = true
  }

  placement {
    availability_zone = aws_subnet.main.availability_zone
  }

  #   user_data = filebase64("${path.module}/assets/bootstrap.sh")
  user_data = base64encode(templatefile("${path.module}/assets/bootstrap.sh.tmpl", { aws_ecs_cluster = aws_ecs_cluster.main.name }))
}


data "aws_ami" "main" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20220520-x86_64-ebs"]
  }
  owners = ["amazon"]
}

# resource "aws_iam_instance_profile" "main" {
#   name = var.project
#   role = aws_iam_role.db_access.name
# }

# resource "aws_iam_role" "db_access" {
#   name = "${var.project}-db-access"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }

resource "aws_security_group" "main" {
  name   = var.project
  vpc_id = aws_vpc.main.id
}
resource "aws_security_group_rule" "in" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}
resource "aws_security_group_rule" "out" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}