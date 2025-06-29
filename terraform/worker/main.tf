## BASE CONFIGURATION

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.69.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true

  random_vm_id_start = 200

  ssh {
    agent       = true
    private_key = file(var.ssh_private_key_path)
  }
}

## Download Ubuntu Cloud Image
resource "proxmox_virtual_environment_download_file" "ubuntu_server_cloudimg" {
  content_type = "iso"
  datastore_id = var.datastore_id
  node_name    = var.node_name
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

## Load SSH Public Key
data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_path
}

## Upload Cloud-Init Configuration for Worker 01
resource "proxmox_virtual_environment_file" "cloud_config_worker01" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: worker01
    users:
      - default
      - name: ubuntu
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
      - curl -sfL https://get.k3s.io | sh -s - agent --server ${var.k3s_server_url} --token "${var.k3s_token}"
    EOF

    file_name = "user-data-cloud-config_worker01.yaml"
  }
}

## Upload Cloud-Init Configuration for Worker 02
resource "proxmox_virtual_environment_file" "cloud_config_worker02" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: worker02
    users:
      - default
      - name: ubuntu
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
      - curl -sfL https://get.k3s.io | sh -s - agent --server ${var.k3s_server_url} --token "${var.k3s_token}"
    EOF

    file_name = "user-data-cloud-config_worker02.yaml"
  }
}

## Worker 01 VM
resource "proxmox_virtual_environment_vm" "worker01" {
  name        = "worker01"
  description = "Managed by Terraform"
  node_name   = var.node_name
  tags        = ["terraform", "ubuntu", "kubernetes", "worker"]

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 12288
  }

  disk {
    datastore_id = var.datastore_lvm
    file_id      = proxmox_virtual_environment_download_file.ubuntu_server_cloudimg.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 100
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.worker01_ip_address
        gateway = var.gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config_worker01.id
  }

  network_device {
    bridge = var.network_bridge
  }
}

## Worker 02 VM
resource "proxmox_virtual_environment_vm" "worker02" {
  name        = "worker02"
  description = "Managed by Terraform"
  node_name   = var.node_name
  tags        = ["terraform", "ubuntu", "kubernetes", "worker"]

  agent {
    enabled = true
  }

  cpu {
    sockets = 2
    cores   = 4
    type    = "host"
  }

  memory {
    dedicated = 12288
  }

  disk {
    datastore_id = var.datastore_lvm
    file_id      = proxmox_virtual_environment_download_file.ubuntu_server_cloudimg.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 250
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.worker02_ip_address
        gateway = var.gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config_worker02.id
  }

  network_device {
    bridge = var.network_bridge
  }
}

## VARIABLES (place in variables.tf)

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox API username"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_ecdsa"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ecdsa.pub"
}

variable "datastore_id" {
  description = "Datastore ID for ISO and snippets"
  type        = string
  default     = "local"
}

variable "datastore_lvm" {
  description = "Datastore ID for VM disk storage"
  type        = string
  default     = "local-lvm"
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "worker01_ip_address" {
  description = "Static IP for worker01 with CIDR"
  type        = string
  default     = "192.168.178.110/24"
}

variable "worker02_ip_address" {
  description = "Static IP for worker02 with CIDR"
  type        = string
  default     = "192.168.178.111/24"
}

variable "gateway" {
  description = "Network gateway"
  type        = string
  default     = "192.168.178.1"
}

variable "network_bridge" {
  description = "Network bridge name"
  type        = string
  default     = "vmbr0"
}

variable "k3s_server_url" {
  description = "K3s master API server URL for agents to join"
  type        = string
  default     = "https://192.168.178.100:6443"
}

variable "k3s_token" {
  description = "K3s cluster token for agent nodes"
  type        = string
}