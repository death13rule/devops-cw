resource "yandex_compute_snapshot_schedule" "backup" {
  folder_id  = var.folder_id
  name       = "backups"

  schedule_policy {
    expression = "0 3 * * *"
  }

  retention_period = "168h"

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.web-a.boot_disk[0].disk_id,
    yandex_compute_instance.web-b.boot_disk[0].disk_id,
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id,
    yandex_compute_instance.es.boot_disk[0].disk_id
  ]
}