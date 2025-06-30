variable "node_name" { type = string }
variable "datastore_id" { type = string }
variable "datastore_lvm" { type = string }
variable "network_bridge" { type = string }
variable "gateway" { type = string }
variable "ssh_public_key_path" { type = string }
variable "k3s_token" {
  type = string
  sensitive = true
}