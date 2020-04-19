data "template_file" "basic_auth_function" {
  template = file("templates/basic-auth.js")

  vars = {
    user     = "hogehoge"
    password = "mogemogemoge"
  }
}

data "archive_file" "basic_auth_function" {
  type        = "zip"
  output_path = "basic-auth.zip"

  source {
    content  = data.template_file.basic_auth_function.rendered
    filename = "basic-auth.js"
  }
}

resource "aws_lambda_function" "basic_auth" {
  # NOTE: Lambda Edge の region は us-east-1 限定
  # https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-how-it-works-tutorial.html
  provider = aws.use1

  filename         = "basic-auth.zip"
  function_name    = "basic-auth-for-cloudfront"
  role             = aws_iam_role.lambda.arn
  handler          = "basic-auth.handler"
  source_code_hash = data.archive_file.basic_auth_function.output_base64sha256
  runtime          = "nodejs12.x"
  description      = "Protect CloudFront distributions with Basic Authentication"
  publish          = true

  depends_on = [aws_cloudwatch_log_group.basic_auth]
}

resource "aws_cloudwatch_log_group" "basic_auth" {
  # NOTE: Lambda Edge の region が us-east-1 限定の為、合わせて us-east-1 で作成
  provider = aws.use1

  name              = "/aws/lambda/basic-auth-for-cloudfront"
  retention_in_days = 1
}
