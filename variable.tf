variable "env" {
  default = "stg"
}

variable "service_name" {
  default = "your_service"
}

variable "domain" {
  default = {
    root           = "your.domain.com"
    cloudfront_app = "cdn.your.domain.com"
  }
}

variable "cloudfront_shared_key" {
  default = "kokohajiyuunikaetene"
}
