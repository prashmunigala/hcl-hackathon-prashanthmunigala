region = "us-east-1"

vpc_cidr_block            = "10.0.0.0/16"
public_subnet_cidr_block  = "10.0.0.0/24"
private_subnet_cidr_block = "10.0.2.0/24"
public_subnet1_cidr_block = "10.0.3.0/24"
private_subnet1_cidr_block = "10.0.4.0/24"

availability_zone = "us-east-1a"
availability_zone1 = "us-east-1b"
availability_zone2 = "us-east-1c"

ingress_ports = [80, 3000, 3001]

ecs_cluster_name       = "hcl_ecs_cluster"
ecr_repository_name    = "hcl_ecr_repo"
lb_name                = "hcl_app_lb"
lb_security_group_name = "hcl_lb_sg"
route_table_name       = "hcl_public_route_table"