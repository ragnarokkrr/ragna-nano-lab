# RagnaHome Lab Project

**An Ansible-driven, modular home lab automation framework for deploying and managing a self-hosted infrastructure.**

## 🧭 Project Overview

RagnaHome Lab aims to provision and manage a modern homelab environment leveraging:
- Ansible automation
- Role-based modularity
- Infrastructure-as-code principles
- Support for NUCs, Raspberry Pi, and VM clusters

Key goals include:
- NAS deployment with ZFS, Samba, Avahi
- Docker-based service orchestration (e.g., CasaOS, Portainer)
- Network segmentation with VLANs and mDNS support
- Lightweight Linux environments (e.g., Lubuntu on Ubuntu Server)
- Power-efficient nodes: GMKTec NucBox, Raspberry Pi 3B

---

## 🧱 Project Structure

```text
ragna-home-lab/
├── README.md
├── inventories/
│   ├── production/
│   │   ├── hosts.ini
│   │   └── group_vars/
├── playbooks/
│   ├── nas.yml
│   ├── zimaos.yml
│   └── common.yml
├── roles/
│   ├── base/
│   ├── samba/
│   ├── zfs/
│   ├── avahi/
│   ├── firewall/
│   └── docker/
├── vars/
│   └── globals.yml
├── files/
├── templates/
└── scripts/
    └── init-ubuntu-server.sh
```

---

## ⚙️ Prerequisites

- Control Node:
  - Python 3.8+
  - Ansible 8+
- Target Nodes:
  - Ubuntu Server (22.04 LTS or newer)
  - SSH enabled with key-based access

To set up your control node:

```bash
sudo apt update
sudo apt install -y ansible git
git clone https://github.com/YOURUSER/ragna-home-lab.git
cd ragna-home-lab
```

---

## 🚀 Usage

### 1. Configure Inventory
Edit `inventories/production/hosts.ini` with your homelab node IPs and roles.

### 2. Define Variables
Populate `group_vars` and `vars/globals.yml` with:
- User accounts
- Network config (static IPs, VLANs)
- Shared folders

### 3. Run Playbooks

```bash
ansible-playbook -i inventories/production nas.yml
ansible-playbook -i inventories/production zimaos.yml
```

---

## 🔧 Features Roadmap

- [x] Static IP assignment
- [x] ZFS pool setup
- [x] Samba + Avahi for cross-platform file sharing
- [x] CasaOS on Docker
- [x] Portainer UI
- [ ] mDNS + Hostname broadcasting
- [ ] VLAN support via switch config
- [ ] CI/CD pipeline integration

---

## 🔐 Security Notes

- SSH key-based access is mandatory
- Avoid hardcoding passwords in playbooks; use `ansible-vault` or `.env` files
- Recommended: use separate Ansible user with sudo privileges

---

## 👨‍💻 Development & Contributions

This project is designed for iterative growth. To add a new service:
1. Create a new role under `roles/<your_service>`
2. Add corresponding tasks, handlers, templates
3. Integrate it in a new or existing playbook

Feel free to fork and submit PRs.

---

## 📘 License

MIT License. See [LICENSE](./LICENSE).

---

## 📞 Support / Contact

Open issues or contact via email at `your.email@domain.com`.
