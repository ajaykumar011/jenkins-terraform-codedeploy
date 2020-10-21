#ALB
output "ALB" {
  value = aws_lb.app-alb.dns_name
}

output "bucket_name" {
  value = aws_s3_bucket.b.bucket_domain_name
}

output "application_name" {
  value = aws_codedeploy_app.main.name
}