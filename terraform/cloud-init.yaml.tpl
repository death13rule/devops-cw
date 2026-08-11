#cloud-config

hostname: ${hostname}

users:
  - default

  - name: ${ansible_user}
    gecos: DevOps Engineer
    groups:
      - sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_key}

package_update: true
package_upgrade: true

packages:
%{ for pkg in packages ~}
  - ${pkg}
%{ endfor }

runcmd:
  - mkdir -p /home/${ansible_user}/.ssh
  - chown -R ${ansible_user}:${ansible_user} /home/${ansible_user}/.ssh