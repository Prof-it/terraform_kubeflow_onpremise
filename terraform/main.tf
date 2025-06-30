terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = false

  ssh {
    agent       = true
    private_key = file(var.ssh_private_key_path)
  }
}

module "k3s_master" {
  source               = "./modules/k3s_master"
  datastore_lvm        = var.datastore_lvm
  datastore_id         = var.datastore_id
  network_bridge       = var.network_bridge
  gateway              = var.gateway
  ssh_public_key_path  = var.ssh_public_key_path
  k3s_token            = var.k3s_token
  node_name            = var.node_name
}

module "k3s_workers" {
  source               = "./modules/k3s_workers"
  datastore_lvm        = var.datastore_lvm
  datastore_id         = var.datastore_id
  network_bridge       = var.network_bridge
  gateway              = var.gateway
  ssh_public_key_path  = var.ssh_public_key_path
  k3s_token            = var.k3s_token
  node_name            = var.node_name
  k3s_server_url       = var.k3s_server_url
}