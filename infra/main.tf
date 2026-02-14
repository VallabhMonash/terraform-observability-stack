module "network" {
  source = "./modules/network"
}

module "app" {
  source       = "./modules/app"
  network_name = module.network.network_name
}

module "monitoring" {
  source       = "./modules/monitoring"
  network_name = module.network.network_name
  scrape_target = "${module.app.container_name}:8000"
}


