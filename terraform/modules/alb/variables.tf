variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "A list of public subnet IDs for ALB deployment"
  type        = list(string)
}
