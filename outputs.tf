output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
}

output "asg_instance_public_ips" {
  value = data.aws_instances.asg_instances.public_ips
}