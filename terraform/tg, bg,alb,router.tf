### Target group ###

resource "yandex_alb_target_group" "web-servers" {
  folder_id  = var.folder_id
  name = "web-target-group"
  target {
      subnet_id = yandex_vpc_subnet.subnet-web-a.id
      ip_address = yandex_compute_instance.web-a.network_interface[0].ip_address
  }
  target {
      subnet_id = yandex_vpc_subnet.subnet-web-b.id
      ip_address = yandex_compute_instance.web-b.network_interface[0].ip_address
  }
}

### Backend group ###

resource "yandex_alb_backend_group" "alb-bg" {
  folder_id  = var.folder_id
  name                     = "alb-bg"
  http_backend {
    name                   = "backend-group"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.web-servers.id]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthcheck_port     = 80
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

### HTTP Router & Virtual host ###

resource "yandex_alb_http_router" "alb-router" {
  folder_id  = var.folder_id
  name              = "alb-router"
}

resource "yandex_alb_virtual_host" "alb-host" {
  name           = "alb-host"
  http_router_id = yandex_alb_http_router.alb-router.id
  route {
    name = "route-1"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb-bg.id
        timeout          = "3s"
      }
    }
  }
}

### ALB ###

resource "yandex_alb_load_balancer" "alb-1" {
folder_id            = var.folder_id
  name               = "alb-1"
  network_id         = yandex_vpc_network.network-1.id
  security_group_ids = [yandex_vpc_security_group.sg-balancer.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-web-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-web-b.id
    }
  }

  listener {
    name = "alb-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.alb-router.id
      }
    }
  }
}