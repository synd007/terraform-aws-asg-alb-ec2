# Input variables for the autoscaling module
variable "image_id" {
  description = "AMI ID for instances"
}
variable "instance_type" {
  description = "Instance type (e.g., t2.micro)"
}
variable "key_name" {
  description = "Key Pair name for SSH"
}
variable "sg_id" {
  description = "Security Group ID to attach"
}
variable "user_data" {
  description = "User Data script for instance initialization"
}

variable "min_size" {
  description = "Minimum asg size"
}
variable "max_size" {
  description = "Maximum asg size"
}
variable "desired_capacity" {
  description = "Desired asg capacity"
}

variable "subnet_ids" {
  description = "List of subnets where instances launch"
  type        = list(string)
}

variable "lb_tg_arn" { 
    description = "Target Group ARN for ALB" 
}