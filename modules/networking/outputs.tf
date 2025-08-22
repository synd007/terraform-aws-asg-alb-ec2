output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.my_vpc.id
}

output "subnet1_id" {
  description = "The ID of public subnet 1"
  value       = aws_subnet.public1.id
}

output "subnet2_id" {
  description = "The ID of public subnet 2"
  value       = aws_subnet.public2.id
}
