terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

data "aws_instances" "public_ec2_instances" {
  instance_tags = {
    Name = "public"
  }

  depends_on = [aws_autoscaling_group.public_auto_scaling_group]
}

resource "aws_autoscaling_group" "public_auto_scaling_group" {
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 5000
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.lb_target_group.arn]
  launch_configuration      = aws_launch_configuration.public_ec2_launch_configuration.name
  vpc_zone_identifier       = [
    var.public_subnet_1_id,
    var.public_subnet_2_id,
  ]

  tag {
    key = "Name"
    value = "public"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "public_ec2_launch_configuration" {
  name                        = "public_ec2_launch_configuration"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [var.public_security_group_id]
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = true
  user_data                   = base64encode(
  <<EOT
    ${file("${path.root}/../scripts/init-ec2.sh")}

    /usr/local/bin/aws s3 cp s3://${var.s3_bucket_name}/jarname.jar jarname.jar
    java -jar jarname.jar &
  EOT
  )
}

resource "aws_instance" "ec2_instance_private" {
  ami                  = var.image_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  subnet_id            = var.private_subnet_1_id
  security_groups      = [var.private_security_group_id]
  iam_instance_profile = var.iam_instance_profile_name
  user_data            = base64encode(
  <<EOT
  ${file("${path.root}/../scripts/init-ec2.sh")}
    /usr/local/bin/aws s3 cp s3://${var.s3_bucket_name}/jarname.jar jarname.jar

    echo 'export RDS_HOST="${var.rds_address}"' >> .bashrc
    source .bashrc

    psql --command='CREATE DATABASE "database_name";' ${var.rds_connect_string}

    java -jar persist3-2021-0.0.1-SNAPSHOT.jar &
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
  subnet_id         = var.public_subnet_1_id
  security_groups   = [var.public_security_group_id]
  source_dest_check = false

  tags = {
    Name = "nat"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "load-balancer-final"
  load_balancer_type = "application"
  security_groups    = [var.public_security_group_id]
  subnets            = [
    var.public_subnet_1_id,
    var.public_subnet_2_id,
  ]

  tags = {
    Name = "load-balancer-final"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "lb-target-group-final"
  target_type = "instance"
  vpc_id      = var.vpc_id
  port        = 80
  protocol    = "HTTP"

  health_check {
    path = "/actuator/health"
    port = 80
  }
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
