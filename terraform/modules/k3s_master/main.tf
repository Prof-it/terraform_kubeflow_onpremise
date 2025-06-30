terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78.2"
    }
  }
}

resource "proxmox_virtual_environment_vm" "master" {
  name        = "k3s-master"
  node_name   = var.node_name
  tags        = ["terraform", "k3s", "master"]

  cpu { cores = 4 }
  memory { dedicated = 8192 }

  disk {
    datastore_id = var.datastore_lvm
    size         = 50
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
  }

  network_device { bridge = var.network_bridge }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.178.100/24"
        gateway = var.gateway
        }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_master.id
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_master" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/cloudinit_master.yaml.tftpl", {
      ssh_key = file(var.ssh_public_key_path)
      k3s_token = var.k3s_token
    })
    file_name = "cloudinit_k3s_master.yaml"
  }
}