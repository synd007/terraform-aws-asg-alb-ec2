# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.aws_vpc_cidr            # VPC CIDR block 

  tags = {
    Name = "MyVPC"                         # Tag for easy identification
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id               # Attach igw to vpc

  tags = {
    Name = "MyInternetGateway"             # Tag for easy identification
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id               # Associate route table with VPC

  # Route all traffic (0.0.0.0/0) to Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Public Subnet 1
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.PublicSubnet1    # Subnet1 CIDR block
  availability_zone       = "us-east-1a"         # Availability Zone for Subnet1
  map_public_ip_on_launch = true                 # Auto-assign Public IP

  tags = {
    Name = "PublicSubnet1"
  }
}

# Public Subnet 2
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.PublicSubnet2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet2"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id            # Associate Subnet1 with Public Route Table
  route_table_id = aws_route_table.public_rt.id     # Associate Public Route Table with Subnet1
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id            
  route_table_id = aws_route_table.public_rt.id     
}
