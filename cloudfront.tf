resource "aws_cloudfront_distribution" "app_alb_distribution" {
  origin {
    domain_name = "your alb domain"
    origin_id   = "alb-app"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "x-cloudfront-shared-key"
      value = var.cloudfront_shared_key
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront-logs"
  }

  aliases = [var.domain["cloudfront_app"]]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE", "PATCH"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "alb-app"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }

      headers = ["*"]
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    # Basic 認証
    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.basic_auth.qualified_arn
    }

    # CSP 設定
    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_lambda_function.csp.qualified_arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false

    acm_certificate_arn      = aws_acm_certificate.cloudfront.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  tags = {
    Name = "${var.env}-${var.service_name}-cloudfront"
    Env  = var.env
  }
}
