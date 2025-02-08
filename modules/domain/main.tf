locals {
  is_production = terraform.workspace == "production"
  is_development = terraform.workspace == "development"
  sub_domain_prefix = local.is_production ? "" : local.is_development ? "dev" : terraform.workspace
  sub_domain_sign = local.is_production ? "" : "."

  domain = var.domain_name
  domain_with_sub = "${local.sub_domain_prefix}${local.sub_domain_sign}${local.domain}"
}

# Check if the hosted zone for the domain already exists
data "aws_route53_zone" "existing_zone" {
  name         = local.domain
  private_zone = false  # Adjust this if you are using private zones
}
#
#resource "aws_route53_zone" "zone" {
#  # todo add conditions to prevent recreation hosted zone for each workspaces.
#  #   possible solution is to remove resource block here and use data block only
#  #   but in this case before init we should manually and separately execute resource block
#  name  = local.domain
#  lifecycle {
#    create_before_destroy = true
#    prevent_destroy       = true
#  }
#}

# Use the hosted zone ID from either the existing or the new one
locals {
#  todo resolve re-creation part
#  hosted_zone_id = length(data.aws_route53_zone.existing_zone.id) > 0 ? data.aws_route53_zone.existing_zone.id : aws_route53_zone.zone.id
  hosted_zone_id = data.aws_route53_zone.existing_zone.id
}

#  ACM will provide DNS validation records in the format of a TXT record. Send DNS Validation Records to the Domain Admin
resource "aws_acm_certificate" "cert" {
  domain_name       = local.domain_with_sub
  validation_method = "DNS"

  tags = {
    Name = local.domain_with_sub
  }
}

resource "aws_route53_record" "cert_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = local.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 300
}
