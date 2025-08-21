data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Name"
    values = ["MyInstance"] 
  }
  depends_on = [aws_autoscaling_group.asg]
}

data "aws_key_pair" "my_key" {
  key_name = "my-key"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = var.aws_vpc_cidr
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}
resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.PublicSubnet1
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true 

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.PublicSubnet2
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true 

  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_launch_template" "launch_config" {
  name                   = "my-launch-configuration"
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.my_key.key_name

   network_interfaces {
    associate_public_ip_address = true
    device_index = 0
    security_groups = [aws_security_group.web_sg.id]
  }
  user_data = base64encode(var.aws_launch_template_user_data)

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
  resource_type = "instance"
  tags = {
    Name = "MyInstance"
  }
}
}

resource "aws_autoscaling_group" "asg" {
  min_size            = var.autoscaling_group_name_min
  max_size            = var.autoscaling_group_name_max
  desired_capacity    = var.autoscaling_group_name_desired

   launch_template {
        id      = aws_launch_template.launch_config.id
        version = "$Latest"
        
    }

  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
}

resource "aws_lb" "my_alb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  enable_deletion_protection = false

  tags = {
    Name = "MyLoadBalancer"
  }
}

resource "aws_lb_target_group" "lb-tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
  }

  tags = {
    Name = "MyTargetGroup"
  }
}

resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }
}

resource "aws_autoscaling_policy" "name" {
  name                   = "scale-out"
  scaling_adjustment      = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.id
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn = aws_lb_target_group.lb-tg.arn
}
