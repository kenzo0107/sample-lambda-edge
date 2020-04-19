data "aws_elb_service_account" "alb" {}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.env}.${var.service_name}.logs"
  acl    = "private"

  force_destroy = true

  tags = {
    Name = "${var.env}-${var.service_name}-lb-logs"
    Env  = var.env
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "logs" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.alb.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs.json
}
