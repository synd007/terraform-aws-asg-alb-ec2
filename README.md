# Terraform AWS Auto Scaling with ALB 
This project provisions a highly available web application on AWS using Terraform. It creates a custom VPC, subnets across availability zones, an Application Load Balancer (ALB), an Auto Scaling Group (ASG) with EC2 instances running Apache, and security groups to allow HTTP and SSH access.

### Architecture
- VPC 
- 2 Public Subnets in different AZs for high availability
- Internet Gateway + Route Table for outbound internet access
- Security Group allowing inbound 80 (HTTP) and 22 (SSH)
- Launch Template for EC2 instances:
   - Ubuntu AMI
  - Apache Web Server installed via user_data
  - Key Pair for SSH access
- Auto Scaling Group (ASG):
  - Min: 1, Max: 2, Desired: 1
  - Deploys EC2 instances across both subnets
- Application Load Balancer (ALB) distributing HTTP traffic to the ASG

### Prerequisites
1. Terraform 
2. AWS CLI configured with IAM credentials
3. An existing AWS Key Pair 
4. Permissions to create VPC, EC2, ALB, and Auto Scaling resources

### Deployment
1. Clone the repository
git clone https://github.com/your-username/aws-terraform-asg-alb.git
- _cd aws-terraform-asg-alb_
2. Initialize Terraform
- _terraform init_
3. Preview the plan
- _terraform plan_
4. Apply the configuration
- _terraform apply -auto-approve_
5. Access the application
 - Copy the ALB DNS name from the Terraform output.
 - Paste it into your browser to see: Welcome to My Web Server
 - or _ssh -i /path/to/key/pair.pem ubuntu@{PublicIp}_
6. To destroy all resources
- _terraform destroy -auto-approve_

### Outputs
alb_dns_name: _Public DNS of the Application Load Balancer_
asg_instance_public_ips: _Public IPs of EC2 instances created by the Auto Scaling Group_

### Author
Eyo John
