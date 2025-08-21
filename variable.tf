variable "region" {
  description = "The AWS region to deploy the resources"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  default     = "my-key"
}

variable "aws_vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "192.168.0.0/16"
}

variable "PublicSubnet1" {
  description = "The CIDR block for the Public Subnet 1"
  default     = "192.168.1.0/25"
}

variable "PublicSubnet2" {
  description = "The CIDR block for the Public Subnet 2"
  default     = "192.168.1.128/25"
}

variable "image_id" {
  description = "The AMI ID to use for the instances"
  default     = "ami-020cba7c55df1f615"
}

variable "aws_launch_template_user_data" {
  description = "The user data script for the launch template"
  default     = <<-EOF
    #!/bin/bash
    # Install Apache web server
    apt update -y
    apt install -y apache2
    echo "Welcome to My Web Server" > /var/www/html/index.html
    systemctl start apache2
    systemctl enable apache2
    EOF
}

variable "autoscaling_group_name_min" {
  description = "The minimum size of the Auto Scaling group"
  default     = 1
}

variable "autoscaling_group_name_max" {
  description = "The maximum size of the Auto Scaling group"
  default     = 2
}

variable "autoscaling_group_name_desired" {
  description = "The desired capacity of the Auto Scaling group"
  default     = 1
}