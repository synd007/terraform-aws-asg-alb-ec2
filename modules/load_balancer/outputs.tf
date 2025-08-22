output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
}

output "tg_arn" {
  value = aws_lb_target_group.lb_tg.arn
}