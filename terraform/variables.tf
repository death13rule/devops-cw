variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "sa_id" {
  description = "Service Account ID"
  type        = string
}

variable "web_image_id" {
  description = "Image ID for Web Servers"
  type        = string
}

variable "mon_image_id" {
  description = "Image ID for Monitoring Servers"
  type        = string
}

variable "ansible_user" {
  description = "SSH user for Ansible"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key"
  type        = string
  sensitive   = true
}

variable "admin_ip" {
  description = "IP admin host"
  type        = string
}