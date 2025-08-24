## Overview

This repository provides a set of **Terraform modules** for deploying a production-ready, on-premise **Kubeflow** environment using **Proxmox VE** as the virtualization platform. It automates the creation of virtual machines, Kubernetes installation (via k3s), and Kubeflow deployment with GPU passthrough support.

Designed for **reproducibility, flexibility**, and **infrastructure-as-code (IaC)** principles.

## Architecture

```
+----------------------------+
|        Proxmox VE         |
+----------------------------+
        |     |     |
     VM1    VM2   ...   VMn
      |      |           |
   [k3s master]   [k3s workers]
        |
   +-------------------+
   |     Kubeflow      |
   +-------------------+
```

- **Proxmox VE**: Hypervisor to host all VMs.
- **Terraform**: Automates the VM provisioning and config.
- **k3s**: Lightweight Kubernetes distribution for simplicity.
- **Kubeflow**: ML workload orchestration platform.
- **GPU support**: Optional passthrough for ML acceleration.

## Features

- 💡 Modular and extensible Terraform setup
- ☁️ Cloud-init support for automated provisioning
- 🧠 Kubeflow 1.x installation (optionally airgapped)
- 🧱 Storage backend integration (e.g., NFS, local)
- 🚀 GPU passthrough ready (e.g., NVIDIA)
- 🔐 Vault/Secrets structure for sensitive data
- 📈 Monitoring ready (Prometheus/Grafana optional)

## Prerequisites

- Proxmox VE 7.x or later
- Terraform 1.x
- SSH key pair for VM access
- Existing storage pool on Proxmox
- [Optional] Local DNS or external ingress setup

## Repository Structure

```
terraform_kubeflow_onpremise/
├── environments/        # Env-specific configs (e.g., dev, prod)
├── modules/
│   ├── k3s_master/      # Proxmox + k3s master node module
│   ├── k3s_worker/      # Proxmox + k3s worker nodes module
│   └── kubeflow/        # Kubeflow installation via kustomize
├── secrets/             # Encrypted variables (Vault)
├── scripts/             # Helper scripts (e.g., config sync)
└── README.md
```

## Usage

1. **Clone this repo**

```bash
git clone https://github.com/Prof-it/terraform_kubeflow_onpremise.git
cd terraform_kubeflow_onpremise/environments/dev
```

2. **Configure variables**

Edit the `terraform.tfvars` or `main.tf` to set:
- Proxmox credentials
- VM specs (CPU, RAM, disk)
- SSH keys
- Cluster name

3. **Initialize Terraform**

```bash
terraform init
```

4. **Review the plan**

```bash
terraform plan
```

5. **Apply the infrastructure**

```bash
terraform apply
```

6. **Access Kubeflow**

After successful deployment, Kubeflow will be accessible via the configured load balancer or ingress IP/domain.

## Secrets Management

Sensitive variables (e.g., Proxmox API credentials) are stored using **Ansible Vault** or **Terraform Vault integration**. See `secrets/README.md` for details.

## GPU Passthrough (optional)

- Ensure IOMMU is enabled in Proxmox
- Add PCI device passthrough config to VM templates
- Enable `nvidia-container-runtime` in worker node setup

## Contributions

We welcome community contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes
4. Submit a pull request

## Acknowledgements

- [Kubeflow](https://www.kubeflow.org/)
- [Terraform](https://www.terraform.io/)
- [Proxmox VE](https://www.proxmox.com/)
- [K3s](https://k3s.io/)

---

📬 For questions or support, please open an issue or contact us via GitHub.
