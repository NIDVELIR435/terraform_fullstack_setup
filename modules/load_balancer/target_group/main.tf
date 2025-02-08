resource "aws_lb_target_group" "target_group" {
  name     = "${terraform.workspace}-${var.target_group_name}-tg"
  port     = var.port
  target_type = "ip"
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    protocol = "HTTP"
    path                = var.health_path
    interval            = 30
    timeout             = 5
    healthy_threshold  = 5
    unhealthy_threshold = 2
  }
}
