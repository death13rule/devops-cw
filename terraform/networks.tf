resource "yandex_vpc_network" "network-1" {
  folder_id        = var.folder_id
  name             = "network-1"
}

### Приватные подсети для web и ES ###

resource "yandex_vpc_subnet" "subnet-web-a" {
    folder_id      = var.folder_id
    name           = "subnet-web-a"
    zone           = "ru-central1-a"
    network_id     = yandex_vpc_network.network-1.id
    v4_cidr_blocks = ["192.168.10.0/24"]
    route_table_id = yandex_vpc_route_table.rt-private.id
}

resource "yandex_vpc_subnet" "subnet-web-b" {
    folder_id      = var.folder_id
    name           = "subnet-web-b"
    zone           = "ru-central1-b"
    network_id     = yandex_vpc_network.network-1.id
    v4_cidr_blocks = ["192.168.11.0/24"]
    route_table_id = yandex_vpc_route_table.rt-private.id
}

resource "yandex_vpc_subnet" "subnet-es-d" {
    folder_id      = var.folder_id
    name           = "subnet-es-d"
    zone           = "ru-central1-d"
    network_id     = yandex_vpc_network.network-1.id
    v4_cidr_blocks = ["192.168.12.0/24"]
    route_table_id = yandex_vpc_route_table.rt-private.id
}

### Публичная подсеть для bastion, zabbix, kibana ###

resource "yandex_vpc_subnet" "subnet-public-a" {
    folder_id      = var.folder_id
    name           = "subnet-public-a"
    zone           = "ru-central1-a"
    network_id     = yandex_vpc_network.network-1.id
    v4_cidr_blocks = ["192.168.20.0/24"]
}

### NAT-шлюз - для обновлений в приватных сетях ###

resource "yandex_vpc_gateway" "nat-gateway" {
    folder_id       = var.folder_id
    name            = "nat-gateway"
    shared_egress_gateway {
    }
}

resource "yandex_vpc_route_table" "rt-private" {
    folder_id          = var.folder_id
    network_id         = yandex_vpc_network.network-1.id
    static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gateway.id
    }
}

