terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}


resource "yandex_vpc_network" "network1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet2" {
  name           = "subnet2"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}


module "mc1" {
  source                = "./modules/instance"
  family_image = "lemp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet1.id
}

module "mc2" {
  source                = "./modules/instance"
  family_image = "lamp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet2.id
  zone           = "ru-central1-a"
}

resource "yandex_lb_network_load_balancer" "load1" {
  name = "lb-1"

  listener {
    name = "listener-web-servers"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web-servers.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

resource "yandex_lb_target_group" "web-servers" {
  name = "web-servers-lbtg"

  target {
    subnet_id = yandex_vpc_subnet.subnet1.id
    address   = module.mc1.internal_ip_address_vm
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet2.id
    address   = module.mc2.internal_ip_address_vm
  }
}
