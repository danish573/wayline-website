output "Jenkins_server_public_ip" {
  description = "Jenkins Server Public IP"
  value = aws_instance.static_webapp.public_ip
}

output "jenkins_server_url" {
  value = "https://${aws_instance.static_webapp.public_ip}:8080"
}

output "s3_website_url" {
  description = "S3 Static Website URL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}