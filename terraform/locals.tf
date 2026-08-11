locals {
  ssh_public_key = trimspace(file("~/.ssh/id_ed25519_yc.pub"))
}