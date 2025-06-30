variable "proxmox_endpoint" { 
    type = string 
}
variable "proxmox_username" { 
    type = string 
}
variable "proxmox_password" {
    type = string
    sensitive = true
}
variable "ssh_private_key_path" { 
    type = string 
    default = "~/.ssh/id_ecdsa" 
}
variable "ssh_public_key_path" { 
    type = string 
    default = "~/.ssh/id_ecdsa.pub" 
}
variable "datastore_id" { 
    type = string 
    default = "local" 
}
variable "datastore_lvm" { 
    type = string 
    default = "local-lvm" 
}
variable "node_name" { 
    type = string 
    default = "pve" 
}
variable "network_bridge" { 
    type = string 
    default = "vmbr0" 
}
variable "gateway" { 
    type = string 
    default = "192.168.178.1" 
}
variable "k3s_token" {
    type = string
    sensitive = true
}
variable "k3s_server_url" { 
    type = string 
    default = "https://192.168.178.100:6443" 
}