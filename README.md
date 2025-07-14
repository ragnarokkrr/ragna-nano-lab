# RagnaNano Lab Project

**An Ansible-driven, modular home lab automation framework for deploying and managing a self-hosted infrastructure.**

## 🧭 Project Overview

RagnaNano Lab is a comprehensive homelab automation platform designed for power-efficient, scalable infrastructure management. The project leverages modern DevOps practices to create a production-ready homelab environment.

### 🎯 Core Objectives
- **Infrastructure as Code**: Full automation using Ansible playbooks
- **Modular Architecture**: Component-based design for easy scaling
- **CI/CD Integration**: Automated testing and deployment pipelines
- **Power Efficiency**: Optimized for low-power ARM and x86 hardware
- **Production Ready**: Enterprise-grade monitoring and management

### 🏗️ Architecture Components
- **NAS Layer**: ZimaOS-based storage with Docker orchestration
- **Compute Fleet**: Raspberry Pi cluster for CI/CD and monitoring
- **Network Infrastructure**: VLAN-segmented managed switching
- **Virtualization**: ProxMox and Kubernetes for workload management
- **Testing Framework**: Vagrant-based validation environment


## 🚀 Quick Start

### Prerequisites
```bash
# Install required tools
sudo apt update
sudo apt install -y ansible git vagrant virtualbox

# Clone the repository
git clone https://github.com/ragnarokkrr/ragna-nano-lab.git
cd ragna-nano-lab
```

### Test Before Deploy
```bash
# Test with Vagrant (recommended)
cd bare-metal/provisioning-tests
./run-all-tests.sh

# Or test individual components
cd bare-metal/provisioning-tests/ragna-nas
vagrant up
```

### Deploy to Hardware
```bash
# Configure your inventory
cp bare-metal/ragna-nas/zimaos-nas/inventories/g9/hosts.ini.example hosts.ini
vim hosts.ini  # Add your hardware IPs

# Deploy NAS infrastructure
cd bare-metal/ragna-nas/zimaos-nas
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml

# Deploy Pi fleet
cd ../../bare-metal/ragna-lab-sidekick
ansible-playbook -i inventory.ini playbook.yml
```

## 📁 Project Structure

```
ragna-nano-lab/
├── 📋 README.md                    # This file
├── 📋 CLAUDE.md                    # Claude Code documentation
├── 📋 LICENSE                      # MIT License
├── 📋 Lab-Hardware-Inventory.md    # Hardware specifications
├── 🏠 bare-metal/                  # Physical infrastructure
│   ├── ragna-nas/                  # NAS deployment
│   │   └── zimaos-nas/             # ZimaOS Ansible automation
│   │       ├── playbooks/          # Main deployment playbooks
│   │       ├── roles/              # Reusable Ansible roles
│   │       └── inventories/        # Environment configurations
│   ├── ragna-lab-sidekick/         # Raspberry Pi fleet
│   │   └── README.md               # Pi deployment guide
│   ├── ragna-router/               # Router configuration
│   ├── ragna-switch/               # Switch VLAN management
│   ├── 💻 ragna-proxmox/           # ProxMox virtualization layer
│   └── 🧪 provisioning-tests/      # Testing infrastructure
│       ├── ragna-nas/              # NAS testing (3-disk setup)
│       ├── ragna-lab-sidekick/     # Pi fleet testing
│       ├── molecule/               # Molecule test framework
│       └── run-all-tests.sh       # Automated test runner
```

---

## 🔐 Security Notes

- SSH key-based access is mandatory
- Avoid hardcoding passwords in playbooks; use `ansible-vault` or `.env` files
- Recommended: use separate Ansible user with sudo privileges

---

## 🗺️ Roadmap

### Phase 1 - Foundation Infrastructure 🏗️
- [x] Vagrant testing environment with 3-disk NAS simulation
- [x] Ansible role structure for modular deployment
- [x] Project documentation and development workflow
- [ ] Basic rack infrastructure setup
- [ ] GMKTec NucBox G9 NAS deployment
- [ ] Raspberry Pi fleet provisioning
- [ ] Network switch configuration
- [ ] Power distribution system

### Phase 2 - CI/CD & Monitoring 🚧
- [ ] Docker Swarm cluster on Raspberry Pi fleet
- [ ] Gitea + Woodpecker CI pipeline
- [ ] Prometheus/Grafana monitoring stack
- [ ] VLAN segmentation implementation
- [ ] mDNS + hostname broadcasting
- [ ] Automated testing pipeline integration

### Phase 3 - Virtualization & Orchestration 📋
- [ ] ProxMox virtualization on additional NucBox units
- [ ] Kubernetes cluster deployment
- [ ] Service mesh implementation
- [ ] Network automation and management
- [ ] Multi-cluster management

### Phase 4 - AI/ML Capabilities 🔮
- [ ] Local LLM deployment
- [ ] GPU acceleration setup
- [ ] ML pipeline integration
- [ ] Edge AI workload management
- [ ] AI-assisted infrastructure optimization

## 🧪 Testing & Development

This project includes comprehensive testing infrastructure:

- **Vagrant Testing**: Full environment simulation before hardware deployment
- **Molecule Framework**: Individual role testing and validation
- **Multi-disk Testing**: 3-disk NAS configuration testing
- **Network Simulation**: VLAN and multi-node testing

See [bare-metal/provisioning-tests/README.md](bare-metal/provisioning-tests/README.md) for detailed testing documentation.

## 🤝 Contributing

Contributions are welcome! This project is designed for iterative growth:

1. **Fork** the repository
2. **Create** a feature branch
3. **Test** your changes with Vagrant
4. **Submit** a pull request

### Development Workflow
```bash
# Test your changes
cd bare-metal/provisioning-tests
./run-all-tests.sh

# Lint Ansible playbooks
ansible-lint bare-metal/ragna-nas/zimaos-nas/playbooks/

# Verify role syntax
ansible-playbook --syntax-check playbooks/site.yml
```

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)**: Technical documentation for Claude Code
- **[Lab Hardware Inventory](Lab-Hardware-Inventory.md)**: Hardware specifications and phases
- **[Provisioning Tests](provisioning-tests/README.md)**: Testing infrastructure guide
- **Component READMEs**: Individual component documentation

## 🛠️ Hardware Requirements

### Minimum Setup
- 1x GMKTec NucBox G9 (or similar mini PC)
- 2x Raspberry Pi 3B+ 
- 1x Managed switch (D-Link DGS-1100-08V2 or equivalent)
- Power distribution system

### Recommended Setup
- Multiple NucBox units for redundancy
- Additional Raspberry Pi units for scaling
- Rack-mount infrastructure
- UPS for power management

See [Lab-Hardware-Inventory.md](Lab-Hardware-Inventory.md) for complete specifications.

---

## 📘 License

MIT License. See [LICENSE](./LICENSE).

---

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/ragnarokkrr/ragna-nano-lab/issues)
- **Email**: ragnarokkrr@gmail.com
- **Documentation**: This repository's wiki and README files

---

*Built with ❤️ for the homelab community*
