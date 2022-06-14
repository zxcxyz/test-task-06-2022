resource "aws_placement_group" "main" {
  name     = var.project
  strategy = "spread"
}
resource "aws_autoscaling_group" "main" {
  desired_capacity    = 2
  min_size            = 1
  max_size            = 2
  placement_group     = aws_placement_group.main.id
  vpc_zone_identifier = [for subnet in aws_subnet.main : subnet.id]
  # suspended_processes = ["ReplaceUnhealthy"]

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
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