terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "network_name" {
  type = string
}

resource "docker_image" "app" {
  name = "obs-app:latest"

  build {
    context    = "${path.root}/../app"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "app" {
  name  = "obs-app"
  image = docker_image.app.image_id

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 8000
    external = 8000
  }
}

output "container_name" {
  value = docker_container.app.name
}


