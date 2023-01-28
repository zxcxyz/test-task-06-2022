resource "aws_placement_group" "main" {
  name     = var.project
  strategy = "spread"
}
resource "aws_autoscaling_group" "main" {
  desired_capacity    = 1
  min_size            = var.autoscaling_min_size
  max_size            = var.autoscaling_max_size
  placement_group     = aws_placement_group.main.id
  vpc_zone_identifier = [for subnet in aws_subnet.main : subnet.id]

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
  }

  # managed by ecs
  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
  depends_on = [aws_subnet.main]
}

resource "aws_launch_template" "main" {
  name = var.project

  disable_api_termination = false

  iam_instance_profile {
    name = aws_iam_instance_profile.cluster.name
  }
  # best way to have latest ecs optimized ami is to look here 
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
  # and here 
  image_id = "ami-029574c9b0349a8a7"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.main.id]
    delete_on_termination       = true
  }

  user_data = base64encode(templatefile("${path.module}/assets/bootstrap.sh.tmpl", { aws_ecs_cluster = aws_ecs_cluster.main.name }))
}

