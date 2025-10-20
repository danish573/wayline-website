output "instance_id" {
  value = aws_instance.wayline_server.id
}

output "public_ip" {
  value = aws_instance.wayline_server.public_ip
}
