### Bastion ###

resource "yandex_vpc_security_group" "sg-bastion" {
    folder_id  = var.folder_id
    name       = "bastion_group"
    network_id = yandex_vpc_network.network-1.id

ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = [var.admin_ip]
    port           = 22
    }

ingress {
    protocol       = "ICMP"
    description    = "Allow ping"
    v4_cidr_blocks = [var.admin_ip]
  }

egress {
    protocol       = "ANY"
    description    = "ANY OUTBOUND"
    v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

### ALB ###

resource "yandex_vpc_security_group" "sg-balancer" {
    folder_id  = var.folder_id
    name       = "balancer_group"
    network_id = yandex_vpc_network.network-1.id

ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
    }

ingress {
    protocol       = "TCP"
    description    = "https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
    }

ingress {
    protocol          = "TCP"
    description       = "Healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
    }

egress {
    protocol       = "ANY"
    description    = "any outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

### Web-servers ###

resource "yandex_vpc_security_group" "sg-web" {
    folder_id  = var.folder_id
    name       = "sg-web"
    network_id = yandex_vpc_network.network-1.id

ingress {
    protocol          = "TCP"
    description       = "http from ALB"
    security_group_id = yandex_vpc_security_group.sg-balancer.id
    port              = 80
    }

ingress {
    protocol          = "TCP"
    description       = "ssh from bastion"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    port              = 22
    }

ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    }

egress {
    protocol       = "ANY"
    description    = "any outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

### Monitoring (Zabbix-Server) ###

resource "yandex_vpc_security_group" "sg-zabbix" {
    folder_id  = var.folder_id
    name       = "zabbix_group"
    network_id = yandex_vpc_network.network-1.id

ingress {
    protocol       = "TCP"
    description    = "zabbix web"
    v4_cidr_blocks = [var.admin_ip]
    port           = 80
    }

ingress {
    protocol          = "TCP"
    description       = "ssh from bastion"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    port              = 22
    }

ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    }


egress {
    protocol       = "ANY"
    description    = "any outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

### Monitoring (Zabbix-agent) ###

resource "yandex_vpc_security_group" "sg-zabbix-agent" {
    folder_id  = var.folder_id
    name       = "zabbix_agent_group"
    network_id = yandex_vpc_network.network-1.id

ingress {
    protocol          = "TCP"
    description       = "Zabbix server to agent"
    security_group_id = yandex_vpc_security_group.sg-zabbix.id
    port              = 10050
  }

egress {
    protocol       = "ANY"
    description    = "ANY outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

### Monitoring (Kibana) ###

resource "yandex_vpc_security_group" "sg-kibana" {
    folder_id  = var.folder_id
    name       = "kibana_group"
    network_id = yandex_vpc_network.network-1.id

ingress {
    protocol       = "TCP"
    description    = "kibana-web"
    v4_cidr_blocks = [var.admin_ip]
    port           = 5601
    }

ingress {
    protocol          = "TCP"
    description       = "ssh from bastion"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    port              = 22
    }

ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    }

egress {
    protocol       = "ANY"
    description    = "any outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

### Elasticsearch ###

resource "yandex_vpc_security_group" "sg-es" {
    folder_id  = var.folder_id
    name       = "elasticsearch_group"
    network_id = yandex_vpc_network.network-1.id

ingress {
    protocol          = "TCP"
    description       = "es from kibana and filebeat"
    security_group_id = yandex_vpc_security_group.sg-kibana.id
    port         = 9200
    }

ingress {
    protocol          = "TCP"
    description       = "es from web (filebeat)"
    security_group_id = yandex_vpc_security_group.sg-web.id
    port         = 9200
    }

ingress {
    protocol          = "TCP"
    description       = "curl check from bastion"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    port         = 9200
    }

ingress {
    protocol          = "TCP"
    description       = "ssh from bastion"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    port              = 22
    }

ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    security_group_id = yandex_vpc_security_group.sg-bastion.id
    }

egress {
    protocol       = "ANY"
    description    = "any outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    }
}