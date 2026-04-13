variable "aws_region" {
  type        = string
  description = "Region for the S3 bucket (CloudFront is global)."
  default     = "us-east-2"
}

variable "name_prefix" {
  type        = string
  description = "Short prefix for resource names (S3 bucket gets a random suffix from AWS)."
  default     = "ah-history-art"
}

variable "cloudfront_price_class" {
  type        = string
  description = "CloudFront price class. PriceClass_100 = US/Canada/Europe; use PriceClass_All for all edge locations."
  default     = "PriceClass_100"

  validation {
    condition = contains(
      ["PriceClass_100", "PriceClass_200", "PriceClass_All"],
      var.cloudfront_price_class
    )
    error_message = "cloudfront_price_class must be PriceClass_100, PriceClass_200, or PriceClass_All."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to supported resources."
  default     = {}
}
