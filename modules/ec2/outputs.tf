output "db_private_ip" {
  value       = aws_instance.private_ec2.private_ip
  description = "Private IP address of the database EC2 instance"
}

output "load_balancer_dns" {
  value       = aws_lb.maged-wordpress-alb.dns_name
  description = "DNS name of the Load Balancer"
}
