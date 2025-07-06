output "instance_id" {
  value = aws_instance.app.id
}

output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "ec2_public_ip" {
  description = "Elastic IP attached to EC2"
  value       = aws_eip.static_ip.public_ip
}
