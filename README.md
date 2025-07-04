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

## 🗺️ Roadmap

### Phase 1 - Basic Infrastructure ✅
- [ ] Basic rack infrastructure setup
- [ ] GMKTec NucBox G9 NAS deployment
- [ ] Raspberry Pi fleet provisioning
- [ ] Network switch configuration
- [ ] Power distribution system

### Phase 2 - CI/CD & Monitoring 🚧
- [] Docker Swarm cluster on Raspberry Pi fleet
- [ ] Gitea + Woodpecker CI pipeline
- [ ] Prometheus/Grafana monitoring stack
- [ ] VLAN segmentation implementation
- [ ] mDNS + hostname broadcasting

### Phase 3 - Virtualization & Orchestration 📋
- [ ] ProxMox virtualization on additional NucBox units
- [ ] Kubernetes cluster deployment
- [ ] Service mesh implementation
- [ ] Network automation and management

### Phase 4 - AI/ML Capabilities 🔮
- [ ] Local LLM deployment
- [ ] GPU acceleration setup
- [ ] ML pipeline integration
- [ ] Edge AI workload management

---

## 📘 License

MIT License. See [LICENSE](./LICENSE).

---

## 📞 Contact

Open issues or contact via email at `ragnarokkrr@gmail.com`.
