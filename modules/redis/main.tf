resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${terraform.workspace}-redis-subnet-group"
  description = "Subnet group for ${terraform.workspace} Redis"
  subnet_ids = data.aws_subnets.default_subnets.ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${terraform.workspace}-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [data.aws_security_group.default.id]

  maintenance_window = "sun:03:00-sun:06:00"
}
