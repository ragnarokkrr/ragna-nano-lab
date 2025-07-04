Provisioning of Raspberry Pi 3 fleet
====================================

The Raspberry Pi fleet serves as a lightweight CI/CD and dashboarding cluster, providing essential development and monitoring services for the RagnaNano Lab infrastructure.

## 🎯 Purpose

The Raspberry Pi fleet is designed for:
- Lightweight CI/CD pipeline (Gitea + Woodpecker CI)
- Monitoring and dashboarding (Prometheus/Grafana)
- Docker Swarm cluster for containerized services
- Development and testing support services

## 📋 Prerequisites

### Hardware Requirements
- 2x Raspberry Pi 3B+ (minimum)
- MicroSD cards (32GB+ recommended, Class 10)
- Network connectivity (Ethernet preferred)
- Power supply for each Pi
- Optional: Cooling solutions for sustained workloads

### Base OS Installation

1. **Download Ubuntu Server 24.04.2 LTS for ARM64**
   ```bash
   # Download the official image
   wget https://ubuntu.com/download/raspberry-pi
   ```

2. **Flash to MicroSD Card**
   ```bash
   # Using Raspberry Pi Imager (recommended)
   sudo snap install rpi-imager
   rpi-imager
   
   # Or using dd (advanced users)
   sudo dd if=ubuntu-24.04.2-preinstalled-server-arm64+raspi.img of=/dev/sdX bs=4M status=progress
   ```

3. **Initial Boot Configuration**
   - Insert SD card into Pi and boot
   - Default credentials: `ubuntu/ubuntu` (will prompt to change password)
   - Connect via Ethernet for initial setup

## 🔧 Initial Configuration

### 1. System Update and Basic Setup
```bash
# Connect to each Pi
ssh ubuntu@<pi-ip-address>

# Update system
sudo apt update && sudo apt upgrade -y

# Set hostname (repeat for each Pi)
sudo hostnamectl set-hostname pi-node-1  # or pi-node-2, etc.

# Configure static IP (optional but recommended)
sudo nano /etc/netplan/50-cloud-init.yaml
```

Example netplan configuration:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.101/24  # Adjust for each Pi
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

Apply network configuration:
```bash
sudo netplan apply
```

### 2. SSH Key Setup

**On your control machine (laptop/desktop):**
```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "ragna-lab-admin"

# Copy public key to each Pi
ssh-copy-id ubuntu@192.168.1.101  # pi-node-1
ssh-copy-id ubuntu@192.168.1.102  # pi-node-2
```

**On each Pi:**
```bash
# Disable password authentication (optional, for security)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

### 3. Install Required Dependencies
```bash
# Install Python3 and pip (required for Ansible)
sudo apt install -y python3 python3-pip python3-venv

# Install Docker prerequisites
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Install git for CI/CD
sudo apt install -y git

# Create ansible user (recommended)
sudo useradd -m -s /bin/bash ansible
sudo usermod -aG sudo ansible
sudo mkdir -p /home/ansible/.ssh
sudo cp /home/ubuntu/.ssh/authorized_keys /home/ansible/.ssh/
sudo chown -R ansible:ansible /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo chmod 600 /home/ansible/.ssh/authorized_keys

# Allow ansible user sudo without password
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
```

### 4. Optional: Install Lubuntu Desktop
```bash
# Install Lubuntu desktop (lightweight GUI)
sudo apt install -y tasksel
sudo tasksel install lubuntu-desktop

# Set default to console (prevent auto-start of GUI)
sudo systemctl set-default multi-user.target

# Start GUI manually when needed
# startx
```

## 🏗️ Ansible Inventory Configuration

Create your inventory file based on your network setup:

```ini
[pi_fleet]
pi-node-1 ansible_host=192.168.1.101 ansible_user=ansible
pi-node-2 ansible_host=192.168.1.102 ansible_user=ansible

[pi_fleet:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

## 🚀 Deployment

Once initial configuration is complete:

```bash
# Test connectivity
ansible all -i inventory.ini -m ping

# Run the playbook
ansible-playbook -i inventory.ini playbook.yml

# Or run specific tags
ansible-playbook -i inventory.ini playbook.yml --tags docker,swarm
```

## 📊 Services Deployed

After successful deployment, the following services will be available:

- **Docker Swarm**: Cluster orchestration
- **Gitea**: Git repository management
- **Woodpecker CI**: Continuous integration pipeline
- **Prometheus**: Metrics collection
- **Grafana**: Monitoring dashboards

## 🔍 Verification

```bash
# Check Docker Swarm status
docker node ls

# Verify services are running
docker service ls

# Check system resources
htop
df -h
```

## 🐛 Troubleshooting

### Common Issues

**SSH Connection Issues:**
```bash
# Regenerate host keys if needed
sudo ssh-keygen -A
sudo systemctl restart sshd
```

**Docker Permission Issues:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again
```

**Memory/Storage Issues:**
```bash
# Clean up Docker
docker system prune -a

# Check disk space
df -h
sudo apt autoremove
```

**Network Connectivity:**
```bash
# Test network connectivity
ping 8.8.8.8
nslookup google.com

# Check network configuration
ip addr show
sudo netplan get
```

## 📚 Next Steps

1. Configure monitoring dashboards in Grafana
2. Set up CI/CD pipelines in Woodpecker
3. Deploy additional services to the swarm
4. Configure backup strategies
5. Set up log aggregation

## 🔗 Related Documentation

- [Main Project README](../README.md)
- [Hardware Inventory](../Lab-Hardware-Inventory.md)
- [Testing Infrastructure](../provisioning-tests/README.md)
- [CLAUDE.md](../CLAUDE.md) for technical details