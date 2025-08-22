# Outputs from the autoscaling module
output "launch_template_id" {
  value = aws_launch_template.launch_config.id   # output the launch template id
}

output "asg_instance_public_ips" {
  value = data.aws_instances.asg_instances.public_ips
}