# RagnaNano NAS - ZimaOS Deployment

This project provides complete automation for deploying a Network Attached Storage (NAS) system on the GMKTec NucBox G9 using Ubuntu Server and ZimaOS with containerized services.

## 🎯 Purpose

The RagnaNano NAS serves as the central storage and services hub for the homelab infrastructure, providing:

- **File Storage**: Network-attached storage with Samba shares
- **Container Platform**: Docker-based service orchestration
- **Web Management**: ZimaOS dashboard for easy administration
- **Service Discovery**: Portainer for container management
- **Network Services**: DHCP, DNS, and network configuration

## 📋 Prerequisites

### Hardware Requirements

- **GMKTec NucBox G9** (or compatible mini PC)
  - Intel processor with virtualization support
  - Minimum 8GB RAM (16GB+ recommended)
  - 2x NVMe SSD slots for storage
  - Gigabit Ethernet port
  - Multiple USB ports for external storage

### Storage Configuration

**Recommended Setup:**
- **Primary Drive**: 256GB+ NVMe SSD for OS and applications
- **Storage Drive(s)**: 1TB+ NVMe SSD(s) for data storage
- **Optional**: External USB drives for backup/cold storage

## 🚀 Initial Hardware Setup

### 1. Hardware Assembly

1. **Install NVMe SSDs**
   - Install primary OS drive in M.2 slot 1
   - Install storage drive in M.2 slot 2 (if using dual drives)

2. **Connect Peripherals**
   - Connect monitor, keyboard, mouse for initial setup
   - Connect Ethernet cable to your network
   - Connect power adapter

### 2. Ubuntu Server Installation

1. **Download Ubuntu Server 24.04 LTS**
   ```bash
   # Download the ISO
   wget https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso
   ```

2. **Create Installation Media**
   ```bash
   # Using dd (Linux/macOS)
   sudo dd if=ubuntu-24.04-live-server-amd64.iso of=/dev/sdX bs=4M status=progress
   
   # Or use Rufus/Balena Etcher on Windows
   ```

3. **Install Ubuntu Server**
   - Boot from USB installation media
   - Select language and keyboard layout
   - Configure network (DHCP initially, static IP later)
   - Configure storage (use entire primary drive)
   - Create initial user account: `ubuntu`
   - Install OpenSSH server (important!)
   - Complete installation and reboot

### 3. Post-Installation Configuration

```bash
# Initial login (local console or SSH)
ssh ubuntu@<nas-ip-address>

# Update system
sudo apt update && sudo apt upgrade -y

# Set static hostname
sudo hostnamectl set-hostname nas-server

# Install essential packages
sudo apt install -y curl wget git vim htop tree
```

## 🔧 Network Configuration

### Configure Static IP

Edit the netplan configuration:
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Example configuration:
```yaml
network:
  version: 2
  ethernets:
    enp2s0:  # Check your interface name with 'ip link'
      dhcp4: false
      addresses:
        - 192.168.1.100/24  # Choose appropriate IP
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
      optional: true
```

Apply the configuration:
```bash
sudo netplan apply
sudo reboot
```

## 🔐 SSH and User Configuration

### 1. SSH Key Setup

**On your control machine:**
```bash
# Generate SSH key if needed
ssh-keygen -t ed25519 -C "ragna-nas-admin"

# Copy public key to NAS
ssh-copy-id ubuntu@192.168.1.100
```

**On the NAS server:**
```bash
# Create dedicated ansible user (recommended)
sudo useradd -m -s /bin/bash ansible
sudo usermod -aG sudo ansible

# Set up SSH for ansible user
sudo mkdir -p /home/ansible/.ssh
sudo cp /home/ubuntu/.ssh/authorized_keys /home/ansible/.ssh/
sudo chown -R ansible:ansible /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo chmod 600 /home/ansible/.ssh/authorized_keys

# Allow ansible user passwordless sudo
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible

# Secure SSH configuration (optional)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
# Set: PermitRootLogin no
sudo systemctl restart sshd
```

### 2. Install Dependencies

```bash
# Install Python3 and dependencies for Ansible
sudo apt install -y python3 python3-pip python3-venv

# Install Docker prerequisites
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Install system monitoring tools
sudo apt install -y htop iotop nethogs ncdu

# Install network utilities
sudo apt install -y net-tools nmap tcpdump

# Install file system utilities
sudo apt install -y parted gdisk e2fsprogs
```

## 💾 Storage Preparation

### Check Available Storage

```bash
# List all block devices
lsblk

# Check disk information
sudo fdisk -l

# Example output:
# /dev/nvme0n1    # Primary drive (OS)
# /dev/nvme1n1    # Secondary drive (data)
```

### Prepare Data Drives (if separate storage drive)

```bash
# Create partition on data drive (if needed)
sudo parted /dev/nvme1n1 mklabel gpt
sudo parted /dev/nvme1n1 mkpart primary ext4 0% 100%

# Format the partition
sudo mkfs.ext4 /dev/nvme1n1p1

# Create mount point
sudo mkdir -p /mnt/storage

# Get UUID for persistent mounting
sudo blkid /dev/nvme1n1p1

# Add to fstab
echo "UUID=<your-uuid> /mnt/storage ext4 defaults 0 2" | sudo tee -a /etc/fstab

# Mount the drive
sudo mount -a
```

## 🏗️ Ansible Inventory Configuration

Create your inventory file in the `ragna-nas/zimaos-nas/inventories/` directory:

```bash
# Copy example inventory
cp inventories/g9/hosts.ini.example inventories/production/hosts.ini
```

Edit the inventory file:
```ini
[nas_servers]
nas-server ansible_host=192.168.1.100 ansible_user=ansible

[nas_servers:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

# Storage configuration
storage_mount_point=/mnt/storage
storage_device=/dev/nvme1n1p1

# Network configuration
nas_ip=192.168.1.100
nas_subnet=192.168.1.0/24
nas_gateway=192.168.1.1
```

## 🚀 Deployment

### 1. Test Connectivity

```bash
cd ragna-nas/zimaos-nas

# Test Ansible connectivity
ansible all -i inventories/production/hosts.ini -m ping

# Check system information
ansible all -i inventories/production/hosts.ini -m setup
```

### 2. Run Deployment

```bash
# Full deployment
ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml

# Deploy specific components
ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml --tags docker
ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml --tags zimaos,portainer

# System hardening (optional)
ansible-playbook -i inventories/production/hosts.ini playbooks/harden-system.yml
```

## 🌐 Access Points

After successful deployment:

| Service | URL | Description |
|---------|-----|-------------|
| ZimaOS Web UI | `http://192.168.1.100` | Main NAS dashboard |
| Portainer | `http://192.168.1.100:9000` | Container management |
| SSH Access | `ssh ansible@192.168.1.100` | Command line access |

## 🔍 Verification

### Check System Status

```bash
# SSH into the NAS
ssh ansible@192.168.1.100

# Check Docker status
sudo systemctl status docker
docker ps

# Check storage
df -h
lsblk

# Check network
ip addr show
ss -tlnp

# Check system resources
htop
```

### Verify Services

```bash
# Check ZimaOS container
docker ps | grep zima

# Check Portainer
docker ps | grep portainer

# Test web interfaces
curl -I http://localhost:80     # ZimaOS
curl -I http://localhost:9000   # Portainer
```

## 🐛 Troubleshooting

### Common Issues

**Docker Installation Issues:**
```bash
# Reinstall Docker
sudo apt remove docker docker-engine docker.io containerd runc
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ansible
```

**Storage Mount Issues:**
```bash
# Check mount status
mount | grep storage
sudo mount -a

# Check filesystem
sudo fsck /dev/nvme1n1p1
```

**Network Connectivity:**
```bash
# Check IP configuration
ip addr show

# Test DNS resolution
nslookup google.com

# Check routing
ip route show
```

**Container Issues:**
```bash
# Check Docker logs
sudo journalctl -u docker.service

# Check container logs
docker logs <container-name>

# Restart Docker service
sudo systemctl restart docker
```

### Performance Optimization

```bash
# Check I/O performance
sudo iotop

# Monitor network usage
sudo nethogs

# Check disk usage
ncdu /

# Optimize systemd services
sudo systemctl disable unnecessary-service
```

## 📚 Next Steps

1. **Configure File Shares**: Set up Samba shares for network access
2. **Set Up Backups**: Configure automated backup strategies
3. **Monitor System**: Set up monitoring and alerting
4. **Security Hardening**: Implement additional security measures
5. **Service Integration**: Connect with Pi fleet for CI/CD

## 🧪 Testing Options

### Automated Testing with Vagrant
For automated testing and CI/CD integration, see the [provisioning-tests](../provisioning-tests/README.md) directory which includes Vagrant-based testing with 3-disk NAS simulation.

### Manual Testing with VirtualBox
For detailed manual testing, debugging, and experimentation with existing Ubuntu Server images, see [VirtualBox-Testing-Guide.md](VirtualBox-Testing-Guide.md). This guide covers:

- Setting up VirtualBox VMs from existing Ubuntu Server images
- Configuring 3-disk storage simulation
- Manual Ansible deployment testing
- Debugging and troubleshooting procedures
- Custom configuration testing scenarios

**When to use each approach:**
- **Vagrant**: Automated testing, standardized environments, CI/CD pipelines
- **VirtualBox Manual**: Debugging issues, testing custom configurations, educational purposes

## 🔗 Related Documentation

- [Main Project README](../README.md)
- [Hardware Inventory](../Lab-Hardware-Inventory.md)  
- [Testing Infrastructure](../provisioning-tests/README.md)
- [VirtualBox Testing Guide](VirtualBox-Testing-Guide.md)
- [CLAUDE.md](../CLAUDE.md) for technical details
- [ZimaOS Documentation](https://zimaos.io/docs/)
- [Portainer Documentation](https://docs.portainer.io/)

## ⚠️ Important Notes

- **Backup First**: Always backup important data before deployment
- **Test Environment**: Use the Vagrant testing environment first
- **Network Planning**: Plan your IP addressing scheme carefully
- **Security**: Change default passwords and secure SSH access
- **Updates**: Keep system and containers updated regularly