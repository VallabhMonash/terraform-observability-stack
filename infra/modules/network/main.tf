terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "observability" {
  name = "observability-net"
}

output "network_name" {
  value = docker_network.observability.name
}

