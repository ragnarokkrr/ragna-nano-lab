# RagnaNano Lab Project

**An Ansible-driven, modular home lab automation framework for deploying and managing a self-hosted infrastructure.**

## 🧭 Project Overview

RagnaNano Lab aims to provision and manage a modern homelab environment leveraging:
- Ansible automation
- Role-based modularity
- Infrastructure-as-code principles
- Support for NUCs, Raspberry Pi, and VM clusters

Key goals include:
- NAS deployment with ZFS, Samba, Avahi
- Docker-based service orchestration (e.g., ZimaOS, Portainer)
- Network segmentation with VLANs and mDNS support
- Lightweight Linux environments (e.g., Lubuntu on Ubuntu Server)
- Power-efficient nodes: GMKTec NucBox, Raspberry Pi 3B


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
