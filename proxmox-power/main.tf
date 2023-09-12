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

  disk {
    type      = "scsi"
    storage   = "local-lvm"
    size      = "64G"
  }

  lifecycle {
    prevent_destroy = true
  }
}
