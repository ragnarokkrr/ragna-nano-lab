# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RagnaHome Lab is an Ansible-driven, modular home lab automation framework for deploying and managing self-hosted infrastructure. The project leverages:

- Ansible automation with role-based modularity
- Infrastructure-as-code principles
- Support for NUCs, Raspberry Pi, and VM clusters
- Docker-based service orchestration (ZimaOS, Portainer)
- Network segmentation with VLANs and mDNS support (3 VLANs: ragna-lab-sidekick, ragna-nas, ragna-virtua)
- Power-efficient nodes: GMKTec NucBox, Raspberry Pi 3B

Project structure:
- `ragna-nas/zimaos-nas/` - Ansible playbooks and roles for NAS deployment
- `ragna-lab-sidekick/` - Raspberry Pi 3 fleet provisioning for helper activities
- `ragna-router/` - Router provisioning using Raspberry Pi with Ubuntu Server 24.04.2 LTS
- `ragna-switch/` - Switch VLAN provisioning for network segmentation

## Architecture

The project follows Infrastructure-as-Code principles using Ansible with a role-based modular structure:

### Key Components
- **Ansible Roles**: Located in `ragna-nas/zimaos-nas/roles/` - each role handles specific services (docker, zimaos, portainer, netplan, firewall)
- **Inventories**: Environment-specific configurations in `ragna-nas/zimaos-nas/inventories/` (g9, homelab)
- **Playbooks**: Main orchestration files in `ragna-nas/zimaos-nas/playbooks/`
- **Variables**: Global and group-specific variables in `group_vars/` and `vars/`

### Service Stack
The main deployment (`site.yml`) provisions a complete ZimaOS-based system with:
- Docker containerization
- ZimaOS dashboard
- Portainer for container management
- Network configuration via Netplan
- UFW firewall rules

## Hardware Inventory

### Phase 1 - Basic Rack Infrastructure
- **GMKTec NucBox G9 NAS** - Primary NAS system
- **Raspberry Pi Model 3 (x2)** - Helper activities and Docker swarm cluster
- **D-Link DGS-1100-08V2** - Managed switch
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
- **Setup**: `sudo apt update && sudo apt install -y ansible git`

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
cd ragna-nas/zimaos-nas/

# Run the complete site deployment
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml

# Run specific roles with tags
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml --tags docker
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml --tags zimaos,portainer

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
- Helper activities for the main lab infrastructure

#### Router Provisioning (`ragna-router/`)
- Raspberry Pi-based router setup
- Ubuntu Server 24.04.2 LTS with optional Lubuntu
- Ansible playbooks for router configuration

#### Switch VLAN Management (`ragna-switch/`)
- VLAN provisioning for network segmentation
- Three network segments:
  - `ragna-lab-sidekick`: Raspberry Pi fleet network
  - `ragna-nas`: NAS and storage network
  - `ragna-virtua`: Virtualization and Kubernetes layer network

### Inventory Management
- Production environment: `inventories/g9/`
- Development/testing: `inventories/homelab/`
- Each inventory has its own `hosts.ini` and `group_vars/all.yml`

### Development Guidelines
- Project designed for iterative growth
- To add new services: create role under `roles/<service_name>/`, add tasks/handlers/templates, integrate in playbook
- SSH key-based authentication configured for ubuntu user