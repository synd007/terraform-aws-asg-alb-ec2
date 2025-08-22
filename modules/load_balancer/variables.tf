variable "sg_id" {
  description = "Security Group ID for the ALB"
}
variable "subnet_ids" {
  description = "Subnets where the ALB will be deployed"
  type        = list(string)
}
variable "vpc_id" {
  description = "VPC ID for Target Group"
}
