resource "aws_security_group" "lb_security_group" {
  name        = "${var.load_balancer_name}_sg"
  description = "Allow 443 and 80 ports inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default_vpc.id
}

# Allow HTTP traffic (port 80) for IPv4
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.lb_security_group.id
  cidr_ipv4         = "0.0.0.0/0" # Allow traffic from all IPv4 addresses
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Allow HTTPS traffic (port 443) for IPv4
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.lb_security_group.id
  cidr_ipv4         = "0.0.0.0/0" # Allow traffic from all IPv4 addresses
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Allow all outbound traffic for IPv4
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Allow all outbound traffic for IPv6
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.lb_security_group.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
