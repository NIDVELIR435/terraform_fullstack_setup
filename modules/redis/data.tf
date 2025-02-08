data "aws_vpc" "default_vpc" {
  default = true
}

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

data "aws_subnets" "default_subnets" {}

