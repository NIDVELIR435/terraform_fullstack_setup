data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_availability_zones" "availability_zones" {}
data "aws_subnets" "default_subnets" {}


data "aws_security_group" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
  filter {
    name   = "group-name"
    values = ["default"]
  }
}
#
# data "aws_acm_certificate" "issued_certificate" {
#   # todo add domain conditions later
#   # domain = "yourdomain.com"
#   statuses = ["ISSUED"]
#   tags = {
#     "type" = "self-signed"
#   }
# }
