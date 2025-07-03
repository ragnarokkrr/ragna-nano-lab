# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RagnaHome Lab is an Ansible-driven home lab automation framework for deploying and managing self-hosted infrastructure. The project consists of modular components organized under:

- `ragna-nas/zimaos-nas/` - Ansible playbooks and roles for NAS deployment
- `ragna-iot/` - IoT-related components (currently empty)

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

### Inventory Management
- Production environment: `inventories/g9/`
- Development/testing: `inventories/homelab/`
- Each inventory has its own `hosts.ini` and `group_vars/all.yml`

### Prerequisites for Development
- Ansible 8+ installed on control node
- Target nodes running Ubuntu Server 22.04+ with SSH access
- SSH key-based authentication configured for ubuntu user