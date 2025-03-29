output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "rds_password" {
  value = random_password.rds.result
  sensitive = true
}

output "loadbalancer_endpoint" {
  value = aws_lb.alb.dns_name
}

# output "public" {
#   value = aws_instance.webserver_pub[*].public_dns
# }

# output "private" {
#   value = aws_instance.webserver[*].private_ip
# }