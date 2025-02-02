provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "core_bank_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "tech4dev"
  }
}

# Subnets
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.core_bank_vpc.id
  cidr_block              = "10.10.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.core_bank_vpc.id
  cidr_block = "10.10.16.0/20"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "core_bank_igw" {
  vpc_id = aws_vpc.core_bank_vpc.id
}

# Route Table
resource "aws_route_table" "core_bank_route_table" {
  vpc_id = aws_vpc.core_bank_vpc.id
}

# Route to Internet Gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.core_bank_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.core_bank_igw.id
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.core_bank_route_table.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.core_bank_route_table.id
}

# Security Group
resource "aws_security_group" "core_bank_sg" {
  vpc_id = aws_vpc.core_bank_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer
resource "aws_lb" "core_bank_lb" {
  name               = "core-bank-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.core_bank_sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

# Key Pair
resource "aws_key_pair" "core_bank_key" {
  key_name   = "core-bank-key"
  public_key = file("~/.ssh/core-bank-key.pub")
}

# EC2 Instances
resource "aws_instance" "core_bank_vm" {
  count         = 25
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.core_bank_key.key_name
  subnet_id     = aws_subnet.subnet_1.id
  security_groups = [aws_security_group.core_bank_sg.id]
  tags = {
    Name = "core-bank-vm-${count.index}"
  }
}

# RDS Database
resource "aws_db_instance" "core_bank_rds" {
  allocated_storage    = 50
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "db.t3.medium"
  username             = "admin"
  password             = "securepassword"
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.core_bank_sg.id]
  skip_final_snapshot  = true
}

# Block Storage
resource "aws_ebs_volume" "core_bank_ebs" {
  availability_zone = "us-east-1a"
  size              = 100
}

# Elastic Cache (Redis)
resource "aws_elasticache_cluster" "core_bank_cache" {
  cluster_id          = "core-bank-cache"
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  parameter_group_name = "default.redis6.x"
}

# Route 53
resource "aws_route53_zone" "core_bank" {
  name = "core-bank.com"
}

resource "aws_route53_record" "core_bank_dns" {
  zone_id = aws_route53_zone.core_bank.zone_id
  name    = "core-bank.com"
  type    = "A"
  alias {
    name                   = aws_lb.core_bank_lb.dns_name
    zone_id                = aws_lb.core_bank_lb.zone_id
    evaluate_target_health = true
  }
}
