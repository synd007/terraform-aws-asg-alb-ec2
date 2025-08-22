<<<<<<< HEAD
=======
# Fetches EC2 instances that match a tag "Name=MyInstance".
# This allows us to get instance details (like IPs) after ASG creates them.
data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Name"
    values = ["MyInstance"] 
  }
  depends_on = [aws_autoscaling_group.asg] # Ensures ASG creates instances first
}

# Fetch existing AWS key pair by name.
# This is needed so we can SSH into the EC2 instances later.
>>>>>>> cd9a1b7ec43e825b6e47a036e2cd9a692aaf6077
data "aws_key_pair" "my_key" {
  key_name = "my-key"
}

<<<<<<< HEAD
# Networking Module (VPC + Subnets)
module "networking" {
  source       = "./modules/networking"
  aws_vpc_cidr = var.aws_vpc_cidr
  PublicSubnet1 = var.PublicSubnet1
  PublicSubnet2 = var.PublicSubnet2
}

# Security Group Module
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.networking.vpc_id
}

# Load Balancer Module
module "load_balancer" {
  source     = "./modules/load_balancer"
  sg_id      = module.security_group.sg_id
  subnet_ids = [module.networking.subnet1_id, module.networking.subnet2_id]
  vpc_id     = module.networking.vpc_id
}

# Autoscaling Module (Launch Template + ASG)
module "autoscaling" {
  source                        = "./modules/autoscaling"
  image_id                      = var.image_id
  instance_type                 = var.instance_type
  key_name                      = data.aws_key_pair.my_key.key_name
  user_data                     = base64encode(var.aws_launch_template_user_data)
  subnet_ids                    = [module.networking.subnet1_id, module.networking.subnet2_id]
  sg_id                         = [module.security_group.sg_id]
  lb_tg_arn                     = module.load_balancer.tg_arn
  min_size                      = var.autoscaling_group_name_min
  max_size                      = var.autoscaling_group_name_max
  desired_capacity              = var.autoscaling_group_name_desired
=======
# Create a custom VVPC to host all networking resources.
resource "aws_vpc" "my_vpc" {
    cidr_block = var.aws_vpc_cidr
}

# Internet Gateway (IGW) for outbound traffic to the internet.
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Public Route Table with a default route to the Internet Gateway.
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

# Associate Public Subnet 1 with the public route table.
resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Public Subnet 2 with the public route table.
resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for web servers
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id = aws_vpc.my_vpc.id

  # Allow HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access from anywhere (note that this is not securem for production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Public Subnet in us-east-1a
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.PublicSubnet1
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true # Ensures instances in this subnet get public IPs

  tags = {
    Name = "PublicSubnet1"
  }
}

# Public Subnet in us-east-1b
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.PublicSubnet2
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet2"
  }
}

# Launch template defines how EC2 instances are created by the ASG.
resource "aws_launch_template" "launch_config" {
  name                   = "my-launch-configuration"
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.my_key.key_name

  # Attach public IPs and security group
  network_interfaces {
    associate_public_ip_address = true
    device_index = 0
    security_groups = [aws_security_group.web_sg.id]
  }

  # User data script (Base64 encoded) that installs Apache and serves a test page
  user_data = base64encode(var.aws_launch_template_user_data)

  lifecycle {
    create_before_destroy = true # Ensures zero downtime updates
  }

  # Tag EC2 instances created by this template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "MyInstance"
    }
  }
}

# Defines how many EC2 instances run and where they are placed.
resource "aws_autoscaling_group" "asg" {
  min_size         = var.autoscaling_group_name_min
  max_size         = var.autoscaling_group_name_max
  desired_capacity = var.autoscaling_group_name_desired

  launch_template {
    id      = aws_launch_template.launch_config.id
    version = "$Latest"
  }

  # Spread instances across both subnets (multi-AZ)
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
}

# ALB distributes HTTP traffic across EC2 instances in the ASG.
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

# Target group where ALB forwards traffic (port 80)
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

# ALB Listener: listens on port 80 and forwards traffic to target group
resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }
}

# Auto scaling policy: increases instance count by 1 when triggered.
resource "aws_autoscaling_policy" "name" {
  name                   = "scale-out"
  scaling_adjustment      = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.id
}

# Attach ASG to ALB Target Group so new instances register automatically.
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.lb-tg.arn
>>>>>>> cd9a1b7ec43e825b6e47a036e2cd9a692aaf6077
}
