data "aws_availability_zones" "all" {}
variable "subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnet_cidrs" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "db_subnet_cidrs" {
  default = ["10.0.20.0/24", "10.0.21.0/24"]
}
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# vpc endpoints for ecs to work with private ec2 instances
resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.main : subnet.id]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.main.id,
  ]
}
resource "aws_vpc_endpoint" "ecs1" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.main : subnet.id]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.main.id,
  ]
}
resource "aws_vpc_endpoint" "ecs2" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.main : subnet.id]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.main.id,
  ]
}

resource "aws_subnet" "main" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.all.names[count.index]
  cidr_block              = var.subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private"
  }
}
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.all.names[count.index]
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public"
  }
}
resource "aws_subnet" "db" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.all.names[count.index]
  cidr_block              = var.db_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "DB"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "Public"
  }
}
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "Private"
  }
}
resource "aws_route_table_association" "main" {
  count          = length(aws_subnet.main)
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}
resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.main.id
}
# nat for instances to pull images
resource "aws_eip" "main" {
  depends_on = [aws_internet_gateway.main]
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


# load balancing
resource "aws_lb" "main" {
  name               = var.project
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# target group is identified in ecs service definition
resource "aws_lb_target_group" "main" {
  name        = var.project
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}