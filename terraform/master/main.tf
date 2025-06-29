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

  random_vm_id_start = 100
  random_vm_id_end   = 110

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

## Upload Cloud-Init Configuration for Master Node
resource "proxmox_virtual_environment_file" "cloud_config_master" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: master
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
      - curl -sfL https://get.k3s.io | sh -s - server --cluster-init --token "your_cluster_token_here"
    EOF

    file_name = "user-data-cloud-config.yaml"
  }
}

## CREATE MASTER VM
resource "proxmox_virtual_environment_vm" "master01" {
  name        = "master01"
  description = "Managed by Terraform"
  node_name   = var.node_name
  tags        = ["terraform", "ubuntu", "kubernetes", "master"]

  agent {
    enabled = true
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 8192
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
        address = var.master_ip_address
        gateway = var.gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config_master.id
  }

  network_device {
    bridge = var.network_bridge
  }
}

## VARIABLES (in variables.tf for clarity)

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox username"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password"
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
  description = "Proxmox datastore ID for ISO/snippets"
  type        = string
  default     = "local"
}

variable "datastore_lvm" {
  description = "Proxmox LVM datastore ID for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "master_ip_address" {
  description = "Static IP address for the master VM (with CIDR)"
  type        = string
  default     = "192.168.178.100/24"
}

variable "gateway" {
  description = "Gateway for the network"
  type        = string
  default     = "192.168.178.1"
}

variable "network_bridge" {
  description = "Network bridge for the VM"
  type        = string
  default     = "vmbr0"
}