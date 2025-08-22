# Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-load-balancer"         # ALB name
  internal           = false                      # Public-facing
  load_balancer_type = "application"              # ALB type
  security_groups    = [var.sg_id]                # Attach SG
  subnets            = var.subnet_ids               # Deploy across subnets

  enable_deletion_protection = false

  tags = {
    Name = "MyLoadBalancer"
  }
}


# Target Group
resource "aws_lb_target_group" "lb_tg" {
  name     = "my-target-group"                    # Target group name
  port     = 80                                   # Forward HTTP traffic
  protocol = "HTTP"
  vpc_id   = var.vpc_id                     # VPC ID for the target group

  health_check {
    healthy_threshold   = 2              # Number of consecutive successful health checks required
    unhealthy_threshold = 2              # Number of consecutive failed health checks required
    timeout             = 5              # Timeout for each health check
    interval            = 30             # Interval between health checks
    path                = "/"            # Health check request path
    protocol            = "HTTP"         # Protocol for health checks
  }

  tags = {
    Name = "MyTargetGroup"
  }
}


# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80                                  # Listener port
  protocol          = "HTTP"                              # Listener protocol

  default_action {
    type             = "forward"                            # Default action type
    target_group_arn = aws_lb_target_group.lb_tg.arn        # Target group ARN
  }
}
