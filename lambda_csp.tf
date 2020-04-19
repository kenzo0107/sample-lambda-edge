data "template_file" "csp_function" {
  template = file("templates/csp.js")
}

data "archive_file" "csp_function" {
  type        = "zip"
  output_path = "csp.zip"

  source {
    content  = data.template_file.csp_function.rendered
    filename = "csp.js"
  }
}

resource "aws_lambda_function" "csp" {
  # NOTE: Lambda Edge の region は us-east-1 限定
  # https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-how-it-works-tutorial.html
  provider = aws.use1

  filename         = "csp.zip"
  function_name    = "csp-for-cloudfront"
  role             = aws_iam_role.lambda.arn
  handler          = "csp.handler"
  source_code_hash = data.archive_file.csp_function.output_base64sha256
  runtime          = "nodejs12.x"
  description      = "Contents Security Policy"
  publish          = true

  depends_on = [aws_cloudwatch_log_group.csp]
}

resource "aws_cloudwatch_log_group" "csp" {
  # NOTE: Lambda Edge の region が us-east-1 限定の為、合わせて us-east-1 で作成
  provider = aws.use1

  name              = "/aws/lambda/csp-for-cloudfront"
  retention_in_days = 1
}
