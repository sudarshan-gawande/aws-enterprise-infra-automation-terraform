variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for launching the EC2 instance"
  type        = string
}

variable "dockerhub_username" {
  description = "DockerHub username"
  type        = string
}

variable "dockerhub_password" {
  description = "DockerHub password"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID used by the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair to access EC2"
  type        = string
}
