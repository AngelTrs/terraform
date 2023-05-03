resource "proxmox_vm_qemu" "svchost" {

  target_node = "power"
  name        = "svchost"

  # imported attributes
  full_clone  = false
  agent       = 1
  balloon     = 8192
  boot        = "cdn"
  cores       = 8
  memory      = 16384
  onboot      = true
  network {
    bridge    = "vmbr0"
    firewall  = false
    macaddr   = "46:E1:2E:CE:32:CB"
    model     = "virtio"
  }

  lifecycle {
    prevent_destroy = true
  }
}

variable "ci_ipconfig_k8" {
  type = string
  default = "ip=192.168.1.101/24,gw=192.168.1.1"
}

variable "ci_nameserver" {
  type = string
  default = "192.168.1.1"
}

variable "ci_custom_k8" {
  type = string
  default = "user=local:snippets/power-debian-userconfig.yaml"
}

resource "proxmox_vm_qemu" "k8" {
  name            = "k8"
  target_node     = "power"
  vmid            = "101"
  desc            = "vm for learning kubernetes"
  clone           = "debian11-cloud"
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
    bridge        = "vmbr0"
  }

  vga {
    type          = "serial0"
  }

  serial {
    id            = 0
    type          = "socket"
  }

  os_type         = "cloud-init"
  ipconfig0       = var.ci_ipconfig_k8
  nameserver      = var.ci_nameserver
  cicustom        = var.ci_custom_k8
}

variable "dev_password" {
  sensitive = true
}
variable "dev_ssh-pub-key" {}

resource "proxmox_lxc" "dev-doe" {
  # required
  target_node     = "power"

  rootfs {
    storage       = "local-lvm"
    size          = "10G"
  }

  network {
    name          = "eth0"
    bridge        = "vmbr0"
    ip            = "192.168.1.160/24"
    gw            = "192.168.1.1"
  }
  
  # optional
  vmid            = 600
  cores           = 1
  memory          = 512
  swap            = 512
  ostemplate      = "local:vztmpl/debian-11-turnkey-lamp_17.1-1_amd64.tar.gz"
  password        = var.dev_password
  ssh_public_keys = var.dev_ssh-pub-key
  start           = true
  unprivileged    = true
  hostname        = "CT600"
  onboot          = true
}

