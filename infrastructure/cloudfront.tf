locals {
  s3_origin_id = "s3-images"

  # AWS-managed policy IDs (stable; documented by AWS). Using these avoids Terraform
  # calling cloudfront:ListCachePolicies / ListOriginRequestPolicies during plan, which
  # many least-privilege IAM users do not have.
  # Cache: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
  # Origin request: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html
  cloudfront_managed_cache_policy_caching_optimized_id           = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  cloudfront_managed_origin_request_policy_cors_s3_origin_id     = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
}

resource "aws_cloudfront_origin_access_control" "images" {
  name                              = "${var.name_prefix}-images-oac"
  description                       = "OAC for ${var.name_prefix} image bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "images" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.name_prefix} image CDN"
  price_class     = var.cloudfront_price_class

  origin {
    domain_name              = aws_s3_bucket.images.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.images.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id          = local.cloudfront_managed_cache_policy_caching_optimized_id
    origin_request_policy_id = local.cloudfront_managed_origin_request_policy_cors_s3_origin_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-images-cdn"
  })
}
