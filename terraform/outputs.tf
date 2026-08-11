### Web A ###

output "web-a_private_ip" {
  description = "Private IP of Web Server A"
  value = yandex_compute_instance.web-a.network_interface[0].ip_address
}

### Web B ###

output "web-b_private_ip" {
  description = "Private IP of Web Server B"
  value = yandex_compute_instance.web-b.network_interface[0].ip_address
}

### Bastion ###

output "bastion_public_ip" {
  description = "Public IP of Bastion Host"
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

### Zabbix ###

output "zabbix_public_ip" {
  description = "Public IP of Zabbix Server"
  value = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}

### Kibana ###

output "kibana_public_ip" {
  description = "Public IP of Kibana"
  value = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}

### Elasticsearch ###

output "elasticsearch_private_ip" {
  description = "Private IP of Elasticsearch"
  value = yandex_compute_instance.es.network_interface[0].ip_address
}

### Application Load Balancer ###

output "alb_public_ip" {
  description = "Application Load Balancer IP"
  value = yandex_alb_load_balancer.alb-1.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

### Ansible inventory ###

output "ansible_inventory" {
  value = templatefile("${path.module}/inventory.tftpl", {
    web_a_ip = yandex_compute_instance.web-a.network_interface[0].ip_address
    web_b_ip = yandex_compute_instance.web-b.network_interface[0].ip_address
    bastion_ip = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
    zabbix_ip  = yandex_compute_instance.zabbix.network_interface[0].ip_address
    kibana_ip  = yandex_compute_instance.kibana.network_interface[0].ip_address
    es_ip      = yandex_compute_instance.es.network_interface[0].ip_address
    ansible_user = var.ansible_user
  })
}