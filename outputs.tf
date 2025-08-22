output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}

output "asg_instance_public_ips" {
  value = module.autoscaling.asg_instance_public_ips
}