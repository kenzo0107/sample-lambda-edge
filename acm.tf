resource "aws_acm_certificate" "main" {
  domain_name       = var.domain["root"]
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain["root"]}",
  ]

  tags = {
    Name = "${var.env}-${var.service_name}-cert-main"
  }
}

resource "aws_acm_certificate" "cloudfront" {
  provider = aws.use1

  domain_name       = var.domain["root"]
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain["root"]}",
  ]

  tags = {
    Name = "${var.service_name}-cert-cloudfront"
  }
}
