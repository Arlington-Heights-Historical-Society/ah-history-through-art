output "s3_bucket_id" {
  description = "S3 bucket name (use with aws s3 sync s3://...)."
  value       = aws_s3_bucket.images.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.images.arn
}

output "cloudfront_distribution_id" {
  description = "Distribution ID (for create-invalidation)."
  value       = aws_cloudfront_distribution.images.id
}

output "cloudfront_domain_name" {
  description = "CloudFront hostname — use https://<this> in Jekyll image URLs."
  value       = aws_cloudfront_distribution.images.domain_name
}

output "cloudfront_url" {
  description = "Base URL for assets (no trailing slash)."
  value       = "https://${aws_cloudfront_distribution.images.domain_name}"
}
