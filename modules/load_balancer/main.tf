locals {
  load_balancer_name = "${terraform.workspace}-lb"
}

module "load_balancer_security_group" {
  source              = "./security_group"
  load_balancer_name  = local.load_balancer_name
}

module "backend_api_target_group" {
  source              = "./target_group"
  target_group_name   = "backend"
  health_path         = "/api/health"
  port                = 8080
}
module "backend_cron_target_group" {
  source              = "./target_group"
  target_group_name   = "backend-cron"
  health_path         = "/api/health"
  port                = 8080
}

module "frontend_target_group" {
  source              = "./target_group"
  target_group_name   = "frontend"
  health_path         = "/"
  port                = 80
}

resource "aws_alb" "load_balancer" {
  name                = local.load_balancer_name
  load_balancer_type  = "application"
  security_groups     = [data.aws_security_group.default.id, module.load_balancer_security_group.id]
  subnets             = data.aws_subnets.default_subnets.ids
}

resource "aws_alb_listener" "https_listener" {
  load_balancer_arn = aws_alb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = module.frontend_target_group.arn
  }
}

resource "aws_alb_listener_rule" "backend_cron_redirect_rule" {
  listener_arn = aws_alb_listener.https_listener.arn
  priority     = 1  # The lower the number, the higher the priority
  action {
    type = "forward"
    target_group_arn = module.backend_cron_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/api/cron/*"]
    }
    #   todo add host header conditions
  }
}

resource "aws_alb_listener_rule" "backend_api_redirect_rule" {
  listener_arn = aws_alb_listener.https_listener.arn
  priority     = 2  # The lower the number, the higher the priority
  action {
    type = "forward"
    target_group_arn = module.backend_api_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
    #   todo add host header conditions
  }
}



resource "aws_alb_listener_rule" "frontend_redirect_rule" {
  listener_arn = aws_alb_listener.https_listener.arn
  priority     = 3  # The lower the number, the higher the priority
  action {
    type = "forward"
    target_group_arn = module.frontend_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
    #   todo add host header conditions
  }
}


resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }
}

module "load_balancer_route_53_record" {
  source = "./route_53_record"
  domain_zone_id          = var.domain_zone_id
  domain_with_sub         = var.domain_with_sub
  load_balancer_dns_name  = aws_alb.load_balancer.dns_name
  load_balancer_zone_id   = aws_alb.load_balancer.zone_id
}
