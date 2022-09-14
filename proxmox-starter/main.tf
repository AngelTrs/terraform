resource "proxmox_vm_qemu" "router" {
  name            = "router"
  target_node     = "starter"
  vmid            = "100"
  iso             = "local:iso/OPNsense-22.7-OpenSSL-dvd-amd64.iso"
  oncreate        = false
  onboot          = true
  
  cpu             = "host"
  sockets         = 1
  cores           = 4
  memory          = 2048
  disk {
    slot          = 0
    size          = "8G"
    type          = "scsi"
    storage       = "local-lvm"
    iothread      = 1
  }

  network {
    model         = "virtio"
    bridge        = "vmbr1"
  }
  network {
    model         = "virtio"
    bridge        = "vmbr2"
  }
  network {
    model         = "virtio"
    bridge        = "vmbr3"
  }
  network {
    model         = "virtio"
    bridge        = "vmbr4"
  }
}

variable "ci_ipconfig" {
  type = string
  default = "ip=192.168.1.2/24,gw=192.168.1.1"
}

variable "ci_nameserver" {
  type = string
  default = "192.168.1.1"
}

variable "ci_custom" {
  type = string
  default = "user=local:snippets/starter-vpn-userconfig.yaml"
}

resource "proxmox_vm_qemu" "vpn" {
  name            = "vpn"
  target_node     = "starter"
  vmid            = "101"
  clone           = "debian11-cloud"
  onboot          = true
  agent           = 1
  
  cpu             = "host"
  sockets         = 1
  cores           = 1
  memory          = 1024

  disk {
    slot          = 0
    size          = "4G"
    type          = "scsi"
    storage       = "local-lvm"
  }

  network {
    model         = "virtio"
    bridge        = "vmbr2"
  }

  vga {
    type          = "serial0"
  }

  serial {
    id            = 0
    type          = "socket"
  }

  os_type         = "cloud-init"
  ipconfig0       = var.ci_ipconfig
  nameserver      = var.ci_nameserver
  cicustom        = var.ci_custom
}
