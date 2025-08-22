data "aws_key_pair" "my_key" {
  key_name = "my-key"
}

# Networking Module (VPC + Subnets)
module "networking" {
  source       = "./modules/networking"
  aws_vpc_cidr = var.aws_vpc_cidr
  PublicSubnet1 = var.PublicSubnet1
  PublicSubnet2 = var.PublicSubnet2
}

# Security Group Module
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.networking.vpc_id
}

# Load Balancer Module
module "load_balancer" {
  source     = "./modules/load_balancer"
  sg_id      = module.security_group.sg_id
  subnet_ids = [module.networking.subnet1_id, module.networking.subnet2_id]
  vpc_id     = module.networking.vpc_id
}

# Autoscaling Module (Launch Template + ASG)
module "autoscaling" {
  source                        = "./modules/autoscaling"
  image_id                      = var.image_id
  instance_type                 = var.instance_type
  key_name                      = data.aws_key_pair.my_key.key_name
  user_data                     = base64encode(var.aws_launch_template_user_data)
  subnet_ids                    = [module.networking.subnet1_id, module.networking.subnet2_id]
  sg_id                         = [module.security_group.sg_id]
  lb_tg_arn                     = module.load_balancer.tg_arn
  min_size                      = var.autoscaling_group_name_min
  max_size                      = var.autoscaling_group_name_max
  desired_capacity              = var.autoscaling_group_name_desired
}
