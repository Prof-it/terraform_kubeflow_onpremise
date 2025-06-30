terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78.2"
    }
  }
}

locals {
  workers = [
    { name = "k3s-worker-01", ip = "192.168.178.110/24", cpu = 4, ram = 12288, disk = 100 },
    { name = "k3s-worker-02", ip = "192.168.178.111/24", cpu = 4, ram = 12288, disk = 100 }
  ]
}

resource "proxmox_virtual_environment_vm" "workers" {
  for_each   = { for idx, w in local.workers : w.name => w }
  name       = each.value.name
  node_name  = var.node_name
  tags       = ["terraform", "k3s", "worker"]

  cpu { cores = each.value.cpu }
  memory { dedicated = each.value.ram }

  disk {
    datastore_id = var.datastore_lvm
    size         = each.value.disk
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
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_worker[each.key].id
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_worker" {
  for_each = { for idx, w in local.workers : w.name => w }

  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/cloudinit_worker.yaml.tftpl", {
      ssh_key    = file(var.ssh_public_key_path)
      k3s_server = var.k3s_server_url
      k3s_token  = var.k3s_token
      hostname   = each.value.name
    })
    file_name = "cloudinit_${each.key}.yaml"
  }
}