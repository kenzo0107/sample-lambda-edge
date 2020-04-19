provider aws {
  region = "ap-northeast-1"
}

provider aws {
  alias  = "use1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
