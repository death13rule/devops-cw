# Курсовой проект "DevOps-инженер". Cтудент Лютиков А.В.

## Задача
Разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/).

## Решение
Согласно условиям поставленной задачи была развёрнута облачная инфраструктура, включающая в себя:
* 2 Виртуальные машины, являющиеся веб-серверами, на которых развёрнут Nginx, располагающиеся в разных зонах доступности, трафик между которыми регулируется посредством Application Load Balancer.
* 1 Виртуальная машина, выполняющая роль Bastion-хоста, посредством которого выполняется управление и настройка остальных виртуальных машин
* 1 Виртуальная машина, являющаяся сервером Elasticsearch, который собирает данные посредством filebeat с двух развёрнутых веб-серверов
* 1 Виртуальная машина, являющаяся сервером Kibana, который визуализирует данные Elasticsearch
* 1 Виртуальная машина, являющаяся сервером Zabbix, который осуществляет мониторинг всей развёрнутой облачной инфраструктуры

Веб-сервера, сервер Elasticsearch располагаются в приватных подсетях и не имеют публичных адресов. Внешний доступ по публичному IP разрешён на серверах Zabbix, Kibana, Bastion, а так же ALB. Доступ возможен только с IP-адреса администратора.

Для всех хостов были настроены Security Groups, таким образом чтобы обеспечить доступ исключительно только для рабочего взаимодействия между хостами, все остальные порты не использующиеся в работе закрыты. Для возможности получения обновлений для приватных подсетей был создан NAT Gateway и таблица маршрутов.

В качестве Backup было настроено расписание Snapshots дисков всех виртуальных машин, которые выполняются ежедневно в 03:00.

Для развёртывания облачной инфраструктуры в Yandex.Cloud был использован инструментарий Terraform, настройка виртуальных машин была произведена посредством Ansible. Конфигурации размещены в данном репозитории.

## Ход выполнения

## 1. Yandex.Cloud
Предварительно были созданы платёжный аккаунт Yandex.Cloud, облако и каталог для размещения инфраструктуры. Создан сервисный аккаунт для возможности управления посредством Terraform.

## 2. Terraform
Выполнена подготовка [конфигурации Terraform](https://github.com/death13rule/devops-cw/tree/ec3a0438bb85ad55ce1de5ea1be2043ab232102d/terraform). Переменные, носящие конфиденциальный характер, такие как folder_id, ssh_public_key, sa_id, ansible_user вынесены в terraform.tfvars, который в свою очередь включен в .gitignore, поэтому данный файл отсутствует в репозитории. Все составляющие элементы инфраструктуры (ВМ, сети, группы безопасности и т.д.) вынесены в отдельные файлы конфигурации для удобства.

Общая структура конфигурации Terraform:

![Terraform config structure](https://github.com/death13rule/devops-cw/blob/ec3a0438bb85ad55ce1de5ea1be2043ab232102d/screenshots/terraform-structure.png)

Проверка конфигурации Terraform (fmt, init, validate):

![Terraform fmt, init, validate](https://github.com/death13rule/devops-cw/blob/ec3a0438bb85ad55ce1de5ea1be2043ab232102d/screenshots/terraform-fmt-init-validate.png)

Terraform plan:

![Terraform plan](https://github.com/death13rule/devops-cw/blob/ec3a0438bb85ad55ce1de5ea1be2043ab232102d/screenshots/terraform-plan.png)

Выполнено развёртывание конфигурации в облаке (Terraform apply):

![Terraform apply](https://github.com/death13rule/devops-cw/blob/ec3a0438bb85ad55ce1de5ea1be2043ab232102d/screenshots/terraform-apply.png)

Для Ansible был подготовлен шаблон inventory.tfpl который сразу выводит актуальные IP адреса из Output в ansible/inventory.ini:

![Terraform output](https://github.com/death13rule/devops-cw/blob/ec3a0438bb85ad55ce1de5ea1be2043ab232102d/screenshots/terraform-apply.png)

## 3. Ansible
Выполнена подготовка [конфигурации Ansible](https://github.com/death13rule/devops-cw/tree/ec3a0438bb85ad55ce1de5ea1be2043ab232102d/ansible). Для удобства навигации и редактирования конфигурации был использован механизм ролей (Roles). Конфиденциальные переменные помещены в Ansible vault.

Общая структура конфигурации Ansible:

![Ansible structure](https://github.com/death13rule/devops-cw/blob/ec3a0438bb85ad55ce1de5ea1be2043ab232102d/screenshots/ansible-structure.png)

Проверка корректности конфигурации осуществлялась посредством syntax-check и lint:

![Ansible syntax check](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/ansible-syntax-check.png)

![Ansible lint](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/ansible-lint.png)

Проверка доступности хостов all ping:

![Ansible all ping](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/ansible-all-ping.png)

После выполнения всех проверок была выполнена настройка хостов (Ansible playbook):

![Ansible playbook](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/ansible-playbook-site.png)

## 3. Проверка развёрнутой инфраструктуры
После разворачивания инфраструктуры была выполнена проверка работоспособности инфраструктуры.

Curl ALB:

![Curl Website](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/curl-website.png)

Curl Elasticsearch (через Bastion):

![Curl Elasticsearch](https://github.com/death13rule/devops-cw/blob/d5fb527f6363a365f484bbc9530051e1a3638e56/screenshots/curl-es.png)

Filebeat test config and output (web-a, через Bastion):

![Filebeat test config and output web-a](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/filebeat-test-output-a.png)

Filebeat test config and output (web-b, через Bastion):

![Filebeat test config and output web-a](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/filebeat-test-config-b.png)

Systemctl Zabbix-server (через Bastion):

![Zabbix-server status](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/systemctl-status-zabbix-server.png)

Systemctl Zabbix-agent (через Bastion):

![Zabbix-agent status](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/systemctl-status-zabbix-agent.png)

Web-сайт (проверка с внешнего IP):

![Web-site](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/web-site.png)

## 4. Zabbix
После проверки инфраструктуры была выполнена настройка Zabbix server. На дашборд вынесены основные метрики работы виртуальных машин, а так же сетевая нагрузка на веб-серверы и монитор проблем по всем хостам.

Zabbix dashboard:

![Zabbix dashboard](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/zabbix-dashboard.png)

## 5. Kibana
Была выполнена настройка Kibana для отображения данных, получаемых от filebeat с веб-серверов:

Kibana:

![Kibana](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/kibana-web.png)

## 6. Yandex.Cloud
Ниже представлены все элементы созданной инфраструктуры из Yandex.Cloud.

Infrastructure map:

![Infrastructure map](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/infrastructure-map.png)

Network and subnets:

![Network](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/network.png)

![Subnets](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/network-subs.png)

NAT Gateway:

![NAT Gateway](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/gateway.png)

Virtual machines:

![VMs](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/virtual-machines.png)

Security Groups:

![All groups](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/sg-all-groups.png)

![SG balancer](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/sg-balancer.png)

![SG bastion](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/sg-bastion.png)

![SG es](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/sg-bastion.png)

![SG kibana](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/sg-kibana.png)

![SG web](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/sg-web.png)

![SG zabbix agent](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/sg-zabbix-agent.png)

![SG zabbix server](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/sg-zabbix.png)

Target group:

![Target group](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/target-groups.png)

Backend group:

![Backend group](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/backend-groups.png)

Application load balancer:

![ALB](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/alb.png)

Application load balancer router:

![ALB Router](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/alb-router.png)

ALB map:

![ALB map](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/balancer-map.png)

Backup schedule:

![Backup](https://github.com/death13rule/devops-cw/blob/8c11270e9f57269a132a18f10f82c5dbbd696561/screenshots/backup-schedule.png)























