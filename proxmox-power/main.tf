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
}

