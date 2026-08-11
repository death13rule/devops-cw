### Web-server A ###

resource "yandex_compute_instance" "web-a" {
  boot_disk {
    initialize_params {
      type       = "network-hdd"
      size       = 5
      image_id   = var.web_image_id
    }
  }
  folder_id          = var.folder_id
  hostname           = "web-a"
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    hostname = "web-a"
    ssh_key = var.ssh_public_key
    ansible_user = var.ansible_user
    packages = [
      "python3",
      "curl"
    ]
  }
  )}
  name = "web-a"
  allow_stopping_for_update = true
  network_interface {
      subnet_id          = yandex_vpc_subnet.subnet-web-a.id
      nat                = false
      security_group_ids  = [
        yandex_vpc_security_group.sg-web.id,
        yandex_vpc_security_group.sg-zabbix-agent.id
        ]
  }
  platform_id = "standard-v3"
  resources {
    memory        = 1
    cores         = 2
    core_fraction = 20
  }
  zone = "ru-central1-a"
  scheduling_policy {  
    preemptible = true
  }
}

### Web-server B ###

resource "yandex_compute_instance" "web-b" {
  boot_disk {
    initialize_params {
      type       = "network-hdd"
      size       = 5
      image_id   = var.web_image_id
    }
  }
  folder_id          = var.folder_id
  hostname           = "web-b"
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    hostname = "web-b"
    ssh_key = var.ssh_public_key
    ansible_user = var.ansible_user
    packages = [
      "python3",
      "curl"
    ]
  }
  )}
  name = "web-b"
  allow_stopping_for_update = true
  network_interface {
      subnet_id          = yandex_vpc_subnet.subnet-web-b.id
      nat                = false
      security_group_ids  = [
        yandex_vpc_security_group.sg-web.id,
        yandex_vpc_security_group.sg-zabbix-agent.id
      ]
  }
  platform_id = "standard-v3"
  resources {
    memory        = 1
    cores         = 2
    core_fraction = 20
  }
  zone = "ru-central1-b"
  scheduling_policy {  
    preemptible = true
  }
}

### Zabbix ###

resource "yandex_compute_instance" "zabbix" {
  boot_disk {
    initialize_params {
      type       = "network-hdd"
      size       = 5
      image_id   = var.mon_image_id
    }
  }
  folder_id          = var.folder_id
  hostname           = "zabbix"
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    hostname = "zabbix"
    ssh_key = var.ssh_public_key
    ansible_user = var.ansible_user
    packages = [
      "python3",
      "curl"
    ]
  })
  }
  name = "zabbix"
  allow_stopping_for_update = true
  network_interface {
      subnet_id          = yandex_vpc_subnet.subnet-public-a.id
      nat                = true
      security_group_ids  = [yandex_vpc_security_group.sg-zabbix.id]
  }
  platform_id = "standard-v3"
  resources {
    memory        = 2
    cores         = 2
    core_fraction = 20
  }
  zone = "ru-central1-a"
  scheduling_policy {  
  preemptible = true
  }
}

### Kibana ###

resource "yandex_compute_instance" "kibana" {
  boot_disk {
    initialize_params {
      type       = "network-hdd"
      size       = 5
      image_id   = var.mon_image_id
    }
  }
  folder_id          = var.folder_id
  hostname           = "kibana"
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    hostname = "kibana"
    ssh_key = var.ssh_public_key
    ansible_user = var.ansible_user
    packages = [
      "python3",
      "curl"
    ]
  })
  }
  name = "kibana"
  allow_stopping_for_update = true
  network_interface {
      subnet_id          = yandex_vpc_subnet.subnet-public-a.id
      nat                = true
      security_group_ids  = [
        yandex_vpc_security_group.sg-kibana.id,
        yandex_vpc_security_group.sg-zabbix-agent.id
        ]
  }
  platform_id = "standard-v3"
  resources {
    memory        = 2
    cores         = 2
    core_fraction = 20
  }
  zone = "ru-central1-a"
  scheduling_policy {  
    preemptible = true
  }
}

### Elasticsearch ###

resource "yandex_compute_instance" "es" {
  boot_disk {
    initialize_params {
      type       = "network-hdd"
      size       = 5
      image_id   = var.web_image_id
    }
  }
  folder_id          = var.folder_id
  hostname           = "es"
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    hostname = "elasticsearch"
    ssh_key = var.ssh_public_key
    ansible_user = var.ansible_user
    packages = [
      "python3",
      "curl"
    ]
  })
  }
  name = "es"
  allow_stopping_for_update = true
  network_interface {
      subnet_id          = yandex_vpc_subnet.subnet-es-d.id
      nat                = false
      security_group_ids  = [
        yandex_vpc_security_group.sg-es.id,
        yandex_vpc_security_group.sg-zabbix-agent.id
        ]
  }
  platform_id = "standard-v3"
  resources {
    memory        = 2
    cores         = 2
    core_fraction = 20
  }
  zone = "ru-central1-d"
  scheduling_policy {  
    preemptible = true
  }
}

### Bastion host ###

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  folder_id   = var.folder_id
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = var.web_image_id
      type     = "network-hdd"
      size     = 5
    }
  }
  hostname = "bastion"
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-public-a.id
    nat                = true
    security_group_ids = [
      yandex_vpc_security_group.sg-bastion.id,
      yandex_vpc_security_group.sg-zabbix-agent.id
      ]
  }
  scheduling_policy {  
    preemptible = true
  }
  metadata = {
  user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    hostname = "bastion"
    ssh_key = var.ssh_public_key
    ansible_user = var.ansible_user
    packages = [
      "ansible",
      "git",
      "curl",
      "vim",
      "jq",
      "python3",
      "python3-pip"
    ]
    }
    )}
}