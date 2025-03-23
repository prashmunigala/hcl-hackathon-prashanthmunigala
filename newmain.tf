# Provider
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "mynewbuckethclprashanth"
    key    = "terraform/state"
    region = "us-east-1"
    use_lockfile = "true"
  }
}

# VPC
resource "aws_vpc" "vpc_hcl" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc_hcl"
  }
}

# Subnets
resource "aws_subnet" "hcl_public_subnet" {
  vpc_id                  = aws_vpc.vpc_hcl.id
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name = "hcl_public_subnet"
  }
}

resource "aws_subnet" "hcl_public_subnet1" {
  vpc_id                  = aws_vpc.vpc_hcl.id
  cidr_block              = var.public_subnet1_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone1
  tags = {
    Name = "hcl_public_subnet1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "hcl_igw" {
  vpc_id = aws_vpc.vpc_hcl.id
  tags = {
    Name = "hcl_igw"
  }
}

# Route Table
resource "aws_route_table" "hcl_public_route_table" {
  vpc_id = aws_vpc.vpc_hcl.id
  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.hcl_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hcl_igw.id
}

resource "aws_route_table_association" "hcl_public_association" {
  subnet_id      = aws_subnet.hcl_public_subnet.id
  route_table_id = aws_route_table.hcl_public_route_table.id
}

# ECS Cluster
resource "aws_ecs_cluster" "hcl_ecs_cluster" {
  name = var.ecs_cluster_name
}

# IAM Role
resource "aws_iam_role" "hcl_ecs_iam_role" {
  name = "hcl_ecs_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "hcl_ecs_role_attachment" {
  name       = "hcl_ecs_role_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.hcl_ecs_iam_role.name]
}

# ECR Repository
resource "aws_ecr_repository" "hcl_ecr_repo" {
  name = var.ecr_repository_name
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "hcl_ecr_repo"
  }
}

# Load Balancer
resource "aws_lb" "hcl_app_lb" {
  name                       = "hcl-app-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.hcl_lb_sg.id]
  subnets                    = [aws_subnet.hcl_public_subnet.id, aws_subnet.hcl_public_subnet1.id]
  enable_deletion_protection = false

  tags = {
    Name = "application-load-balancer"
  }
}

# Security Group
resource "aws_security_group" "hcl_lb_sg" {
  name        = var.lb_security_group_name
  description = "Allow inbound access"
  vpc_id      = aws_vpc.vpc_hcl.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.hcl_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "ECS Application Load Balancer"
      status_code  = "200"
    }
  }
}