provider "docker" {}

# Crear la red docker
resource "docker_network" "outlinewiki" {
  name     = var.network_name
  internal = false
}

# Redis container
resource "docker_image" "redis" {
  name = "redis:latest"
}

resource "docker_container" "redis" {
  name  = "wk-redis"
  image = docker_image.redis.latest
  restart = "always"
  networks_advanced {
    name = docker_network.outlinewiki.name
  }
}

# Postgres container
resource "docker_image" "postgres" {
  name = "postgres:${var.postgres_version}"
}

resource "docker_container" "postgres" {
  name  = "wk-postgres"
  image = docker_image.postgres.latest
  environment = {
    POSTGRES_USER     = var.postgres_user
    POSTGRES_PASSWORD = var.postgres_password
    POSTGRES_DB       = var.postgres_db
  }
  volumes = [
    "${path.module}/data/pgdata:/var/lib/postgresql/data"
  ]
  restart = "always"
  networks_advanced {
    name = docker_network.outlinewiki.name
  }
}

# Outline container
resource "docker_image" "outline" {
  name = "outlinewiki/outline:${var.outline_version}"
}

resource "docker_container" "outline" {
  name  = "wk-outline"
  image = docker_image.outline.latest
  command = "sh -c 'yarn db:migrate --env production-ssl-disabled && yarn start'"
  environment = {
    DATABASE_URL      = "postgres://${var.postgres_user}:${var.postgres_password}@wk-postgres:5432/${var.postgres_db}"
    DATABASE_URL_TEST = "postgres://${var.postgres_user}:${var.postgres_password}@wk-postgres:5432/outline-test"
    REDIS_URL         = "redis://wk-redis:6379"
    AWS_S3_UPLOAD_BUCKET_NAME = var.aws_s3_bucket_name
  }
  env_file = [
    "${path.module}/env.outline",
    "${path.module}/env.oidc"
  ]
  volumes = [
    "${path.module}/data/outline:/var/lib/outline/data"
  ]
  restart = "always"
  depends_on = [
    docker_container.postgres,
    docker_container.redis
  ]
  networks_advanced {
    name = docker_network.outlinewiki.name
  }
}

# OIDC server container
resource "docker_image" "oidc" {
  name = "vicalloy/oidc-server"
}

resource "docker_container" "oidc_server" {
  name  = "wk-oidc-server"
  image = docker_image.oidc.latest
  volumes = [
    "${path.module}/config/uc/fixtures:/app/oidc_server/fixtures:z",
    "${path.module}/data/uc/db:/app/db:z",
    "${path.module}/data/uc/static_root:/app/static_root:z"
  ]
  restart = "always"
  env_file = ["${path.module}/env.oidc-server"]
  networks_advanced {
    name = docker_network.outlinewiki.name
  }
}

# Nginx container
resource "docker_image" "nginx" {
  name = "nginx"
}

resource "docker_container" "nginx" {
  name  = "wk-nginx"
  image = docker_image.nginx.latest
  ports {
    internal = 80
    external = var.http_port
    ip       = var.http_ip
  }
  volumes = [
    "${path.module}/config/nginx:/etc/nginx/conf.d:ro",
    "${path.module}/data/uc/static_root:/uc/static_root:ro"
  ]
  restart = "always"
  depends_on = [
    docker_container.outline,
    docker_container.oidc_server
  ]
  networks_advanced {
    name = docker_network.outlinewiki.name
  }
}
