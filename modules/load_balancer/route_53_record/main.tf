resource "aws_route53_record" "lb_record" {
  zone_id = var.domain_zone_id
  name    = var.domain_with_sub
  type    = "A"
  alias {
    name                   = var.load_balancer_dns_name
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }
}
