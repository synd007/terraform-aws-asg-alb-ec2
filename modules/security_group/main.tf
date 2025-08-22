# Security Group for Web + SSH
resource "aws_security_group" "web_sg" {
  name        = "web_sg"                        # Security group name
  description = "Allow HTTP and SSH traffic"    # SG description
  vpc_id      = var.vpc_id                     # Attach security group to VPC

  # Allow inbound HTTP (80)
  ingress {
    from_port   = 80                # HTTP port
    to_port     = 80                
    protocol    = "tcp"             # Protocol type
    cidr_blocks = ["0.0.0.0/0"]     # Open to public access
  }

  # Allow inbound SSH (22)
  ingress {
    from_port   = 22                # SSH port
    to_port     = 22
    protocol    = "tcp"              
    cidr_blocks = ["0.0.0.0/0"]      
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0                 # All ports
    to_port     = 0
    protocol    = "-1"              # All protocols
    cidr_blocks = ["0.0.0.0/0"]     # Open to public access
  }

  tags = {
    Name = "WebSecurityGroup"        # Name of the security group
  }
}


