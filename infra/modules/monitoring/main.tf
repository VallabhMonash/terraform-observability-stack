terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "network_name" {
  type = string
}

variable "scrape_target" {
  type = string
}

resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "local_file" "prometheus_config" {
  filename = abspath("${path.root}/prometheus.yml")

  content = <<-YAML
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "obs-app"
    static_configs:
      - targets: ["${var.scrape_target}"]
YAML
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.image_id

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 9090
    external = 9090
  }

  volumes {
    host_path      = abspath(local_file.prometheus_config.filename)
    container_path = "/etc/prometheus/prometheus.yml"
  }

  command = ["--config.file=/etc/prometheus/prometheus.yml"]
}

resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.image_id

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 3000
    external = 3000
  }

  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=admin"
  ]
}

