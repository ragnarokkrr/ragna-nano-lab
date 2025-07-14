# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RagnaNano Lab is an Ansible-driven, modular home lab automation framework for deploying and managing self-hosted infrastructure. The project leverages:

- Ansible automation with role-based modularity
- Infrastructure-as-code principles
- Support for NUCs, Raspberry Pi, and VM clusters
- Docker-based service orchestration (ZimaOS, Portainer)
- Network segmentation with VLANs and mDNS support (3 VLANs: ragna-lab-sidekick, ragna-nas, ragna-proxmox)
- Power-efficient nodes: GMKTec NucBox, Raspberry Pi 3B

Project structure:
- `bare-metal/ragna-nas/zimaos-nas/` - Ansible playbooks and roles for NAS deployment
- `bare-metal/ragna-lab-sidekick/` - Raspberry Pi 3 fleet provisioning for helper activities
- `bare-metal/ragna-router/` - Router provisioning using Raspberry Pi with Ubuntu Server 24.04.2 LTS
- `bare-metal/ragna-switch/` - Switch VLAN provisioning for network segmentation
- `bare-metal/ragna-proxmox/` - ProxMox virtualization and Kubernetes orchestration
- `bare-metal/provisioning-tests/` - Vagrant-based testing infrastructure for validation

## Architecture

The project follows Infrastructure-as-Code principles using Ansible with a role-based modular structure:

### Key Components
- **Ansible Roles**: Located in `bare-metal/ragna-nas/zimaos-nas/roles/` - each role handles specific services (docker, zimaos, portainer, netplan, firewall, lubuntu)
- **Inventories**: Environment-specific configurations in `bare-metal/ragna-nas/zimaos-nas/inventories/` (g9, homelab)
- **Playbooks**: Main orchestration files in `bare-metal/ragna-nas/zimaos-nas/playbooks/`
- **Variables**: Global and group-specific variables in `group_vars/` and `vars/`

### Service Stack
The main deployment (`site.yml`) provisions a complete ZimaOS-based system with:
- Docker containerization
- ZimaOS dashboard
- Portainer for container management
- Network configuration via Netplan
- UFW firewall rules
- Optional Lubuntu desktop environment with VNC support

## Hardware Inventory

### Phase 1 - Basic Rack Infrastructure
- **GMKTec NucBox G9 NAS** - Primary NAS system (12GB RAM, 3x 4TB NVMe 2280 SSDs)
- **Raspberry Pi Model 3 (x2)** - CI/CD and dashboarding cluster
- **D-Link DGS-1100-08V2** - Managed network switch
- **GeeekPi DeskPi RackMate TT Mini Server Cabinet** - Rack infrastructure
- **Glitfix 500W USB C Charger Station** - Power distribution

### Phase 2 - Virtualization (Planned)
- Additional NucBox units with at least 64GB RAM for ProxMox
- Kubernetes capabilities
- WiFi Router addition

### Phase 3 - Local LLM (Planned)
- AI/ML workload support

## Prerequisites

- **Control Node**: Python 3.8+, Ansible 8+
- **Target Nodes**: Ubuntu Server (24.04 LTS or newer) with SSH key-based access
- **Testing Environment**: Vagrant for local Ansible provisioning testing
- **Setup**: `sudo apt update && sudo apt install -y ansible git vagrant`

## Security Notes

- SSH key-based access is mandatory
- Avoid hardcoding passwords in playbooks; use `ansible-vault` or `.env` files
- Recommended: use separate Ansible user with sudo privileges

## Development & Contributions

This project is designed for iterative growth. To add a new service:
1. Create a new role under `roles/<your_service>`
2. Add corresponding tasks, handlers, templates
3. Integrate it in a new or existing playbook

Feel free to fork and submit PRs.

## Common Development Commands

### Ansible Operations
```bash
# Navigate to the main Ansible directory
cd bare-metal/ragna-nas/zimaos-nas/

# Run the complete site deployment
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml

# Run specific roles with tags
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml --tags docker
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml --tags zimaos,portainer
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml --tags lubuntu

# Deploy to different environments
ansible-playbook -i inventories/homelab/hosts.ini playbooks/site.yml

# Run specific playbooks
ansible-playbook -i inventories/g9/hosts.ini playbooks/deploy-apps.yml
ansible-playbook -i inventories/g9/hosts.ini playbooks/harden-system.yml

# Check syntax
ansible-playbook --syntax-check playbooks/site.yml

# Dry run
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml --check
```

### Testing

#### Vagrant Testing
```bash
# Navigate to testing directory
cd bare-metal/provisioning-tests

# Test specific components
cd ragna-nas && vagrant up
cd ragna-lab-sidekick && vagrant up

# Run all tests
./run-all-tests.sh

# SSH into test environment
vagrant ssh

# Destroy test environment
vagrant destroy
```

#### Molecule Testing
```bash
# Test individual roles with Molecule (from role directory)
cd roles/zimaos/
molecule test

# Run converge for development testing
molecule converge
```

### Configuration Management
The default inventory is set to `inventories/g9/hosts.ini` in `ansible.cfg`. Target hosts are configured with SSH key-based authentication using the ubuntu user.

## Working with This Codebase

### Adding New Services
1. Create a new role under `roles/<service_name>/`
2. Add tasks in `roles/<service_name>/tasks/main.yml`
3. Include the role in `playbooks/site.yml` or create a dedicated playbook
4. Add any required variables to `group_vars/` or `vars/`

### Network Infrastructure Components

#### Raspberry Pi Fleet Management (`ragna-lab-sidekick/`)
- Ubuntu Server 24.04.2 LTS base installation
- Optional Lubuntu desktop environment
- Ansible and SSH support
- Docker swarm cluster capabilities
- Lightweight CI/CD and Dashboarding
- Gitea + Woodpecker CI provisioning
- Prometheus/Grafana dashboarding

#### Router Provisioning (`ragna-router/`)
- Raspberry Pi-based router setup
- Ansible playbooks for router configuration
- Status: TBD (To Be Determined)

#### Switch VLAN Management (`ragna-switch/`)
- Ansible playbooks for provisioning VLANs on managed network switch
- VLAN provisioning for network segmentation
- Three network segments:
  - `ragna-lab-sidekick`: Raspberry Pi fleet network
  - `ragna-nas`: NAS and storage network
  - `ragna-proxmox`: ProxMox virtualization and Kubernetes layer network

#### ProxMox Virtualization (`ragna-proxmox/`)
- ProxMox VE virtualization platform deployment
- Kubernetes cluster orchestration
- VM and container management
- High availability and clustering
- Status: Planned for Phase 2

#### Testing Infrastructure (`provisioning-tests/`)
- Vagrant-based local testing environment
- Multi-component validation with VirtualBox
- Molecule framework for individual role testing
- Automated test runner for CI/CD integration

### Inventory Management
- Production environment: `inventories/g9/`
- Development/testing: `inventories/homelab/`
- Each inventory has its own `hosts.ini` and `group_vars/all.yml`

### Development Guidelines
- Project designed for iterative growth
- To add new services: create role under `roles/<service_name>/`, add tasks/handlers/templates, integrate in playbook
- SSH key-based authentication configured for ubuntu user