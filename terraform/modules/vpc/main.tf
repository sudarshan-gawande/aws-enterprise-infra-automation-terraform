# VPC Module - Creates a public VPC with subnets, IGW, and route table
# Maintained by: Sudarshan Gawande
# Portfolio     : https://sudarshangawande.com
# GitHub        : https://github.com/sudarshan-gawande
# LinkedIn      : https://www.linkedin.com/in/sudarshangawande

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "main-vpc"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-1"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-2"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "main-igw"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "public-rt"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
