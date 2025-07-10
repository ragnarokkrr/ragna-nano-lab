# RagnaNano Lab - Provisioning Tests

This directory contains the testing infrastructure for validating Ansible provisioning scripts before deploying to actual hardware. The testing environment uses Vagrant with VirtualBox to simulate the target hardware configurations.

## 🏗️ Infrastructure Overview

### Directory Structure
```
provisioning-tests/
├── README.md                    # This file
├── ragna-lab-sidekick/         # Raspberry Pi fleet testing
│   ├── Vagrantfile
│   └── inventory.ini
├── ragna-nas/                  # NAS server testing
│   ├── Vagrantfile
│   └── inventory.ini
└── molecule/                   # Molecule testing framework
    ├── molecule.yml
    ├── converge.yml
    └── verify.yml
```

## 📋 Prerequisites

Install the required tools on your development machine:

```bash
# Install Vagrant and VirtualBox
sudo apt update
sudo apt install vagrant virtualbox

# Install Ansible and Molecule
sudo apt install ansible
pip3 install molecule[vagrant]

# Verify installations
vagrant --version
ansible --version
molecule --version
```

## 🧪 Testing Environments

### Ragna Lab Sidekick (Raspberry Pi Fleet)

**Purpose**: Test Raspberry Pi provisioning, Docker Swarm cluster, CI/CD pipeline (Gitea + Woodpecker), and monitoring stack (Prometheus/Grafana).

**Configuration**:
- 2 VMs simulating Raspberry Pi 3 constraints
- 1GB RAM, 1 CPU per VM
- Ubuntu 24.04 LTS base
- Private network: 192.168.56.11-12

**Usage**:
```bash
cd provisioning-tests/ragna-lab-sidekick

# Start the test environment
vagrant up

# Run Ansible provisioning
vagrant provision

# SSH into nodes
vagrant ssh pi-node-1
vagrant ssh pi-node-2

# Destroy environment
vagrant destroy -f
```

### Ragna NAS (Network Attached Storage)

**Purpose**: Test NAS server provisioning with ZimaOS, Docker services, Portainer, and network configuration.

**Configuration**:
- 1 VM simulating GMKTec NucBox G9
- 4GB RAM, 4 CPUs
- 3 additional 10GB disks for ZFS testing and storage arrays
- Ubuntu 24.04 LTS base
- Private network: 192.168.56.100

**Port Forwarding**:
- ZimaOS Web UI: http://localhost:8080
- Portainer: http://localhost:9000
- Samba: Port 445 (if enabled)

**Usage**:
```bash
cd provisioning-tests/ragna-nas

# Start the test environment
vagrant up

# Access web interfaces
open http://localhost:8080  # ZimaOS
open http://localhost:9000  # Portainer

# SSH into server
vagrant ssh nas-server

# Destroy environment
vagrant destroy -f
```

## 🔬 Molecule Testing

Molecule provides advanced testing capabilities for individual Ansible roles with automated verification.

**Configuration**:
- Driver: Vagrant with VirtualBox
- Platform: Ubuntu 24.04 LTS
- Test VM: 2GB RAM, 2 CPUs
- Network: 192.168.56.200

**Usage**:
```bash
cd provisioning-tests

# Run full molecule test cycle
molecule test

# Individual test phases
molecule create     # Create test instance
molecule converge   # Run Ansible playbook
molecule verify     # Run verification tests
molecule destroy    # Clean up

# Login to test instance for debugging
molecule login
```

## 🚀 Testing Workflows

### 1. Development Workflow
```bash
# 1. Develop/modify Ansible roles
vim ../ragna-nas/zimaos-nas/roles/docker/tasks/main.yml

# 2. Test with molecule (fast feedback)
cd provisioning-tests
molecule test

# 3. Test full scenario with Vagrant
cd ragna-nas
vagrant up
# Verify services are working
vagrant destroy -f
```

### 2. CI/CD Integration
```bash
# Run all tests in sequence
./run-all-tests.sh

# Individual component testing
./test-ragna-nas.sh
./test-ragna-lab-sidekick.sh
```

### 3. Debugging Failed Provisioning
```bash
# Keep environment running for debugging
vagrant up --no-provision

# Run specific Ansible playbook with verbose output
ansible-playbook -i inventory.ini ../../ragna-nas/zimaos-nas/playbooks/site.yml -vvv

# SSH and inspect manually
vagrant ssh
```

## 📊 Test Scripts

Create these helper scripts for common testing scenarios:

### run-all-tests.sh
```bash
#!/bin/bash
set -e

echo "Running Molecule tests..."
cd molecule && molecule test && cd ..

echo "Testing ragna-nas..."
cd ragna-nas && vagrant up && vagrant destroy -f && cd ..

echo "Testing ragna-lab-sidekick..."
cd ragna-lab-sidekick && vagrant up && vagrant destroy -f && cd ..

echo "All tests completed successfully!"
```

### test-ragna-nas.sh
```bash
#!/bin/bash
cd provisioning-tests/ragna-nas
vagrant up
echo "NAS services available at:"
echo "- ZimaOS: http://localhost:8080"
echo "- Portainer: http://localhost:9000"
echo "Press Enter to destroy environment..."
read
vagrant destroy -f
```

## 🔧 Customization

### Adding New Test Scenarios
1. Create new directory under `provisioning-tests/`
2. Add `Vagrantfile` with appropriate VM configuration
3. Create `inventory.ini` for Ansible
4. Reference the target playbook path
5. Document in this README

### Modifying Resource Allocation
Adjust VM resources in Vagrantfile based on your development machine:
```ruby
vb.memory = "2048"  # Increase for better performance
vb.cpus = 2         # Adjust CPU count
```

### Network Configuration
Modify IP ranges if conflicts occur:
```ruby
node.vm.network "private_network", ip: "192.168.57.#{10 + i}"
```

## 🐛 Troubleshooting

### Common Issues

**VirtualBox Issues**:
```bash
# Check VirtualBox status
systemctl status virtualbox

# Reinstall VirtualBox kernel modules
sudo /sbin/vboxconfig
```

**Vagrant SSH Issues**:
```bash
# Regenerate SSH keys
vagrant ssh-config
ssh-keygen -f ~/.ssh/known_hosts -R "[127.0.0.1]:2222"
```

**Ansible Connection Issues**:
```bash
# Test connectivity
ansible all -i inventory.ini -m ping

# Debug SSH connection
ansible all -i inventory.ini -m setup -vvv
```

**Resource Constraints**:
- Reduce VM memory allocation if host system is constrained
- Run one test environment at a time
- Use `vagrant halt` instead of `destroy` to preserve state

## 📝 Best Practices

1. **Always test locally** before deploying to hardware
2. **Use version pinning** for Vagrant boxes to ensure consistency
3. **Document test scenarios** for complex setups
4. **Clean up environments** after testing to free resources
5. **Version control test configurations** alongside main code
6. **Use meaningful test data** that simulates production scenarios

## 🔗 Integration with Main Project

The testing infrastructure is designed to work seamlessly with the main RagnaNano Lab project:

- Vagrantfiles reference actual Ansible playbooks from `../bare-metal/ragna-nas/` and `../bare-metal/ragna-lab-sidekick/`
- Inventory files use standard Ansible conventions
- Test results validate real deployment scenarios
- Failed tests indicate issues that would occur in production

This ensures that successful tests provide high confidence for actual hardware deployment.