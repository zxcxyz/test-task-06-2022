resource "aws_ecs_cluster" "main" {
  name = var.project
}
resource "aws_ecs_capacity_provider" "main" {
  name = var.project

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.main.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.main.name
  }
}
resource "aws_ecs_service" "node" {
  name            = "${var.project}-nodejs"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.node.arn
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.main.id]
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  }
  # to be used with LBs
  #   iam_role        = aws_iam_role.foo.arn
  #   depends_on      = [aws_iam_role_policy.foo]


}
resource "aws_ecs_task_definition" "node" {
  family       = "nodejs"
  network_mode = "awsvpc"
  container_definitions = jsonencode([
    {
      name      = "nodejs"
      image     = "ghcr.io/benc-uk/nodejs-demoapp:latest"
      essential = true
      memory    = 256
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}