terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

data "aws_availability_zones" "availability_zones" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-aws-for-devs"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.availability_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-aws-for-devs"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.availability_zones.names[1]

  tags = {
    Name = "private-subnet-aws-for-devs"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway-aws-for-devs"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table-aws-for-devs"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_default_route_table" "private_default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = ""
    instance_id = aws_instance.nat_instance.id
  }

  tags = {
    Name = "default-route-table-aws-for-devs"
  }
}

resource "aws_security_group" "public_security_group" {
  description = "Allow SSH/HTTP access to public EC2 instance"
  name_prefix = "public_security_group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_security_group" {
  description = "Allow SSH access to private EC2 instance"
  name_prefix = "private_security_group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance_public" {
  ami             = var.image_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public_security_group.id]

  user_data = base64encode(
  <<EOT
      ${file("${path.module}/../scripts/init-ec2-week4.sh")}
      echo "<html><h1>This is WebServer from public subnet</h1></html>" > index.html
  EOT
  )

  tags = {
    Name = "public"
  }
}

resource "aws_instance" "ec2_instance_private" {
  ami             = var.image_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_security_group.id]

  user_data = base64encode(
  <<EOT
      ${file("${path.module}/../scripts/init-ec2-week4.sh")}
      echo "<html><h1>This is WebServer from private subnet</h1></html>" > index.html
  EOT
  )

  tags = {
    Name = "private"
  }
}

resource "aws_instance" "nat_instance" {
  ami               = "ami-0b30d20498f355d0d"
  instance_type     = "t2.micro"
  key_name          = var.key_name
  subnet_id         = aws_subnet.public_subnet.id
  security_groups   = [aws_security_group.public_security_group.id]
  source_dest_check = false

  tags = {
    Name = "nat"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "load-balancer-aws-for-devs"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_security_group.id]
  subnets            = [
    aws_subnet.public_subnet.id,
    aws_subnet.private_subnet.id,
  ]

  tags = {
    Name = "load-balancer-aws-for-devs"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "lb-target-group-aws-for-devs"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
  port        = 80
  protocol    = "HTTP"

  health_check {
    path     = "/index.html"
    port     = 80
  }
}

resource "aws_lb_target_group_attachment" "lb_target_group_attachment_private" {
  port             = 80
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id        = aws_instance.ec2_instance_private.id
}

resource "aws_lb_target_group_attachment" "lb_target_group_attachment_public" {
  port             = 80
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id        = aws_instance.ec2_instance_public.id
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}