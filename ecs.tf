resource "aws_ecs_cluster" "main" {
  name = var.project
}

resource "aws_ecs_capacity_provider" "main" {
  name = var.project

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.main.arn

    managed_scaling {
      maximum_scaling_step_size = var.autoscaling_max_step
      minimum_scaling_step_size = var.autoscaling_min_step
      status                    = "ENABLED"
      target_capacity           = var.autoscaling_max_utilization
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
    subnets          = [for subnet in aws_subnet.main : subnet.id]
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "nodejs"
    container_port   = 3000
  }
  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }
  deployment_controller {
    type = "ECS"
  }
  lifecycle {
    # terraform tries to delete default capacity provider strategy for some reason
    ignore_changes = [
      capacity_provider_strategy,
    ]
  }
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
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name : "TODO_MONGO_CONNSTR"
          # todo change to separate user
          #mongodb://dbuser:passpasspass@hubstaff-test.crv9iyyj5l4u.eu-west-1.docdb.amazonaws.com:27017/?retryWrites=false
          #mongodb://dbuser:passpasspass@hubstaff-test.crv9iyyj5l4u.eu-west-1.docdb.amazonaws.com:27017/?retryWrites=false
          # value : "mongodb://dbuser:passpasspass@hubstaff-test.crv9iyyj5l4u.eu-west-1.docdb.amazonaws.com:27017/?retryWrites=false"
          value : "mongodb://${aws_docdb_cluster.main.master_username}:${aws_docdb_cluster.main.master_password}@${aws_docdb_cluster_instance.main.endpoint}:${aws_docdb_cluster_instance.main.port}/?retryWrites=false"
        }
      ]
    }
  ])
}