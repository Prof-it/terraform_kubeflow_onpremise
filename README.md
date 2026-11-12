## Overview

This repository provides **Terraform modules for a reproducible on-prem Kubeflow environment on Proxmox VE (k3s, GPU passthrough), accompanying the paper below**. It automates the creation of virtual machines, Kubernetes (k3s) installation, and Kubeflow deployment with optional GPU passthrough support, following infrastructure-as-code (IaC) principles.

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
├── experiment/           # Experiment results and test clusters
│   ├── MulitNodeClusterTest/   # Multi-node test artifacts
│   ├── MultiNodecluster_merged_training_metrics.csv
│   ├── Single_node_training_metrics.csv
│   └── SingleNodeTest/        # Single-node test artifacts
├── kubeflow/             # ML workflow scripts and Kubeflow workloads
│   ├── MultiNodeTest.py       # Distributed TF training example
│   ├── SingleNodeTest.py      # Single-node TF training example
│   └── tf-notebook.yaml       # Jupyter notebook deployment spec
├── terraform/             # Main Terraform configuration
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars       # (Needs user configuration/fix)
│   └── modules/               # Module subdirectory for cluster/kubeflow infra
└── README.md
```

**experiment/** contains test outputs and reproducibility artifacts for ML benchmarking.

**kubeflow/** contains scripts and manifests used for real ML jobs and interactive notebooks on the deployed Kubeflow platform.

**terraform/** is the entry point for all infrastructure provisioning. All `terraform` commands should be run from this directory.


## Usage

1. **Clone this repository**
   ```bash
   git clone https://github.com/Prof-it/terraform_kubeflow_onpremise.git
   ```

2. **Configure Terraform**
   - Change directory to the Terraform config:
     ```bash
     cd terraform_kubeflow_onpremise/terraform
     ```
   - Edit `terraform.tfvars` (create/fix as needed) and variables (`main.tf`, `variables.tf`) to set:
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
   - After successful deployment, Kubeflow will be accessible via the configured load balancer or ingress IP/domain.

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

## Citation

If you use this repository, please cite the following publication:

```bibtex
@article{kramer2025reproducible,
  author    = {Julian Kramer and Tianxiang Lu},
  title     = {A Reproducible Framework for Benchmarking Machine Learning Operations (MLOps) Infrastructures: Comparing Bare-Metal and Orchestrated Machine Learning Workflows},
  journal   = {Cureus Journal of Computer Science},
  year      = {2025},
  publisher = {Springer Nature},
  doi       = {10.7759/s44389-025-08693-x}
}
```

Open Access: [https://doi.org/10.7759/s44389-025-08693-x](https://doi.org/10.7759/s44389-025-08693-x)


---

📬 For questions or support, please open an issue or contact us via GitHub.
