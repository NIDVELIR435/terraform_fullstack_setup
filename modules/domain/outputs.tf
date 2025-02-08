output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}
output "zone_id" {
  value = local.hosted_zone_id
}
output "domain_with_sub" {
  value = local.domain_with_sub
}
