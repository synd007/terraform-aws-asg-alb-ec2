# Launch Template
resource "aws_launch_template" "launch_config" {
  name          = "my-launch-configuration1"
  key_name      = var.key_name              # Key pair for SSH access
  image_id      = var.image_id              # AMI ID for the instance
  instance_type = var.instance_type         # Instance type

  network_interfaces {
    associate_public_ip_address = true      #This Ensure instances get public IPs
    device_index                = 0             # Attach primary network interface
    security_groups             = var.sg_id   # Attachs Security Group
  }

  user_data = base64encode(var.user_data)     #Apache setup

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "MyInstance" }    # Tags instance for easy identification
  }
  lifecycle {
    create_before_destroy = true       # Ensure new instances are created before old ones are destroyed
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  min_size            = var.min_size            # the minimum number of instances
  max_size            = var.max_size            # the max number of instances
  desired_capacity    = var.desired_capacity    # desired instance count
  vpc_zone_identifier = var.subnet_ids          # Subnets to launch instances in

  launch_template {
    id      = aws_launch_template.launch_config.id       # Use the above Launch Template
    version = "$Latest"                         # Always use latest LT version
  }
}

# Attach ASG to ALB Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id   # Reference ASG
  lb_target_group_arn    = var.lb_tg_arn                  # Attach to ALB Target Group
}

# Data Source to get ASG instances
data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Name"
    values = ["MyInstance"]  # Must match launch template tag
  }
  depends_on = [aws_autoscaling_group.asg]
}