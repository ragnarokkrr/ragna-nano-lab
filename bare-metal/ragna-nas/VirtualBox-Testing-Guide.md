# VirtualBox Manual Testing Guide for RagnaNano NAS

This guide provides step-by-step instructions for manually testing the RagnaNano NAS deployment using VirtualBox with a pre-existing Ubuntu Server image.

## 🎯 Purpose

Manual VirtualBox testing allows you to:
- Test Ansible playbooks before deploying to actual hardware
- Validate configurations in a controlled environment
- Debug deployment issues without affecting production systems
- Experiment with different storage configurations
- Practice the deployment workflow

## 📋 Prerequisites

### Software Requirements
- **VirtualBox**: Version 6.1+ or 7.0+
- **VirtualBox Extension Pack**: For enhanced features
- **Ansible**: Installed on your host machine
- **SSH Client**: For connecting to the VM

### Hardware Requirements (Host Machine)
- **RAM**: 8GB+ (to allocate 4GB to VM)
- **Storage**: 50GB+ free space for VM and virtual disks
- **CPU**: Multi-core processor with virtualization support

### Existing Assets
- **Ubuntu Server Image**: Pre-configured Ubuntu Server 24.04 LTS VM or OVA file
- **Network Access**: Host machine connected to network

## 🚀 VirtualBox VM Setup

### 1. Import or Create Ubuntu Server VM

#### Option A: Import Existing OVA/OVF
```bash
# Import existing VM image
VBoxManage import ubuntu-server-24.04.ova --vsys 0 --vmname "ragna-nas-test"

# Or use VirtualBox GUI:
# File > Import Appliance > Select your .ova/.ovf file
```

#### Option B: Clone Existing VM
```bash
# Clone an existing Ubuntu Server VM
VBoxManage clonevm "ubuntu-server-base" --name "ragna-nas-test" --register

# Or use VirtualBox GUI:
# Right-click VM > Clone > Full Clone
```

### 2. Configure VM Settings

#### Basic Configuration
```bash
# Set memory (4GB recommended)
VBoxManage modifyvm "ragna-nas-test" --memory 4096

# Set CPU cores
VBoxManage modifyvm "ragna-nas-test" --cpus 4

# Enable virtualization features
VBoxManage modifyvm "ragna-nas-test" --hwvirtex on
VBoxManage modifyvm "ragna-nas-test" --nestedpaging on
```

#### Network Configuration
```bash
# Set up bridged networking for real network access
VBoxManage modifyvm "ragna-nas-test" --nic1 bridged --bridgeadapter1 "eth0"

# Or use NAT with port forwarding
VBoxManage modifyvm "ragna-nas-test" --nic1 nat
VBoxManage modifyvm "ragna-nas-test" --natpf1 "ssh,tcp,,2222,,22"
VBoxManage modifyvm "ragna-nas-test" --natpf1 "zimaos,tcp,,8080,,80"
VBoxManage modifyvm "ragna-nas-test" --natpf1 "portainer,tcp,,9000,,9000"
```

### 3. Add Storage Disks

Create additional virtual disks to simulate the NAS storage configuration:

```bash
# Create storage directory
mkdir -p ~/VirtualBox\ VMs/ragna-nas-test/storage

# Create first NVMe SSD (40GB to simulate 4TB NVMe SSD)
VBoxManage createhd --filename ~/VirtualBox\ VMs/ragna-nas-test/storage/nvme-ssd-1.vdi --size 40960

# Create second NVMe SSD (40GB to simulate 4TB NVMe SSD)
VBoxManage createhd --filename ~/VirtualBox\ VMs/ragna-nas-test/storage/nvme-ssd-2.vdi --size 40960

# Create third NVMe SSD (40GB to simulate 4TB NVMe SSD)
VBoxManage createhd --filename ~/VirtualBox\ VMs/ragna-nas-test/storage/nvme-ssd-3.vdi --size 40960

# Attach NVMe SSDs to VM (simulating NVMe 2280 form factor)
VBoxManage storageattach "ragna-nas-test" --storagectl "SATA" --port 1 --device 0 --type hdd --medium ~/VirtualBox\ VMs/ragna-nas-test/storage/nvme-ssd-1.vdi
VBoxManage storageattach "ragna-nas-test" --storagectl "SATA" --port 2 --device 0 --type hdd --medium ~/VirtualBox\ VMs/ragna-nas-test/storage/nvme-ssd-2.vdi
VBoxManage storageattach "ragna-nas-test" --storagectl "SATA" --port 3 --device 0 --type hdd --medium ~/VirtualBox\ VMs/ragna-nas-test/storage/nvme-ssd-3.vdi
```

### 4. Start the VM

```bash
# Start VM in headless mode
VBoxManage startvm "ragna-nas-test" --type headless

# Or start with GUI for initial setup
VBoxManage startvm "ragna-nas-test" --type gui
```

## 🔧 VM Initial Configuration

### 1. Get VM IP Address

```bash
# Method 1: Check VirtualBox DHCP leases
VBoxManage guestproperty get "ragna-nas-test" "/VirtualBox/GuestInfo/Net/0/V4/IP"

# Method 2: Connect via console to check IP
VBoxManage guestcontrol "ragna-nas-test" run --exe "/bin/ip" --username ubuntu --password ubuntu -- addr show

# Method 3: Use NAT port forwarding (if configured)
# SSH to localhost:2222
```

### 2. SSH Connection Setup

```bash
# Connect to VM (replace with actual IP)
ssh ubuntu@192.168.1.150

# Or if using NAT with port forwarding
ssh -p 2222 ubuntu@localhost
```

### 3. Prepare VM for Ansible

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Set hostname
sudo hostnamectl set-hostname nas-test-vm

# Install required packages
sudo apt install -y python3 python3-pip curl wget git

# Create ansible user
sudo useradd -m -s /bin/bash ansible
sudo usermod -aG sudo ansible

# Set up SSH keys (copy from host)
ssh-copy-id ubuntu@192.168.1.150
# or for a NAT configuration (copy from host)
ssh-copy-id -p 2222 ubuntu@127.0.0.1

sudo mkdir -p /home/ansible/.ssh
sudo cp /home/ubuntu/.ssh/authorized_keys /home/ansible/.ssh/
sudo chown -R ansible:ansible /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo chmod 600 /home/ansible/.ssh/authorized_keys

# Configure passwordless sudo
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
```

### 4. Configure Static IP (Optional)

```bash
# Edit netplan configuration
sudo nano /etc/netplan/00-installer-config.yaml
```

Example configuration:
```yaml
network:
  version: 2
  ethernets:
    enp0s3:  # Check interface name with 'ip link'
      dhcp4: false
      addresses:
        - 192.168.1.150/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

Apply configuration:
```bash
sudo netplan apply
```

### 5. Configure WiFi Connection (Optional)

If you need to connect Ubuntu Server to WiFi (useful for laptops or when Ethernet is not available):

#### Check WiFi Hardware
```bash
# Check for WiFi interfaces
ip link show

# Check WiFi hardware
lshw -C network

# Check wireless extensions
iwconfig
```

#### Install WiFi Tools
```bash
# Install wireless tools
sudo apt update
sudo apt install -y wireless-tools wpasupplicant

# For WPA3 support (optional)
sudo apt install -y wpa-supplicant
```

#### Configure WiFi with Netplan
```bash
# Edit netplan configuration
sudo nano /etc/netplan/00-installer-config.yaml
```

Example WiFi configuration:
```yaml
network:
  version: 2
  wifis:
    wlp3s0:  # Check your WiFi interface name with 'ip link'
      dhcp4: true
      access-points:
        "Your-WiFi-Network-Name":
          password: "your-wifi-password"
      # Optional: static IP configuration
      # dhcp4: false
      # addresses:
      #   - 192.168.1.151/24
      # gateway4: 192.168.1.1
      # nameservers:
      #   addresses:
      #     - 1.1.1.1
      #     - 8.8.8.8

  # Keep ethernet configuration if needed
  ethernets:
    enp0s3:
      dhcp4: true
```

For WPA3 or enterprise networks:
```yaml
network:
  version: 2
  wifis:
    wlp3s0:
      dhcp4: true
      access-points:
        "Enterprise-Network":
          auth:
            key-management: eap
            method: ttls
            anonymous-identity: "anonymous@university.edu"
            identity: "your-username@university.edu"
            password: "your-password"
```

#### Apply WiFi Configuration
```bash
# Generate and apply configuration
sudo netplan generate
sudo netplan apply

# Check connection status
ip addr show
iwconfig

# Test connectivity
ping google.com
```

#### Troubleshooting WiFi Issues
```bash
# Restart networking service
sudo systemctl restart systemd-networkd

# Check WiFi status
sudo wpa_cli status

# Scan for available networks
sudo iwlist scan | grep ESSID

# Check system logs
sudo journalctl -u systemd-networkd -f

# Reset network configuration if needed
sudo netplan --debug apply
```

#### Alternative: Manual WiFi Setup
If netplan doesn't work, use wpa_supplicant directly:

```bash
# Create WPA supplicant configuration
sudo wpa_passphrase "Your-WiFi-Network" "your-password" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf

# Connect manually
sudo wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
sudo dhclient wlp3s0

# Make it persistent
sudo systemctl enable wpa_supplicant@wlp3s0.service
```

## 🏗️ Ansible Testing Setup

### 1. Create Test Inventory

Create a dedicated inventory file for VirtualBox testing:

```bash
# In your ragna-nas project directory
mkdir -p bare-metal/ragna-nas/zimaos-nas/inventories/virtualbox
```

Create `bare-metal/ragna-nas/zimaos-nas/inventories/virtualbox/hosts.ini`:
```ini
[nas_servers]
nas-test-vm ansible_host=192.168.1.150 ansible_user=ansible

[nas_servers:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

# Storage configuration for VirtualBox
storage_mount_point=/mnt/storage
storage_device=/dev/sdb1

# Network configuration
nas_ip=192.168.1.150
nas_subnet=192.168.1.0/24
nas_gateway=192.168.1.1
```

For NAT networking, use:
```ini
[nas_servers]
nas-test-vm ansible_host=localhost ansible_port=2222 ansible_user=ansible
```

### 2. Test Ansible Connectivity

```bash
cd bare-metal/ragna-nas/zimaos-nas

# Test connection
ansible all -i inventories/virtualbox/hosts.ini -m ping

# Check system information
ansible all -i inventories/virtualbox/hosts.ini -m setup

# Verify storage disks
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "lsblk"
```

## 🚀 Running Ansible Deployment

### 1. Pre-deployment Checks

```bash
# Check disk layout
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "sudo fdisk -l"

# Check network configuration
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "ip addr show"

# Verify available resources
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "free -h && df -h"
```

### 2. Deploy Components

```bash
# Deploy Docker first
ansible-playbook -i inventories/virtualbox/hosts.ini playbooks/site.yml --tags docker

# Deploy ZimaOS
ansible-playbook -i inventories/virtualbox/hosts.ini playbooks/site.yml --tags zimaos

# Deploy Portainer
ansible-playbook -i inventories/virtualbox/hosts.ini playbooks/site.yml --tags portainer

# Full deployment
ansible-playbook -i inventories/virtualbox/hosts.ini playbooks/site.yml
```

### 3. Monitor Deployment

```bash
# Watch deployment progress
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "docker ps"

# Check service logs
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "sudo journalctl -u docker -f --lines=20"
```

## 🔍 Testing and Validation

### 1. Access Web Interfaces

#### For Bridged Networking:
- **ZimaOS**: http://192.168.1.150
- **Portainer**: http://192.168.1.150:9000

#### For NAT Networking:
- **ZimaOS**: http://localhost:8080
- **Portainer**: http://localhost:9000

### 2. SSH Testing

```bash
# SSH into the VM
ssh ansible@192.168.1.150

# Or with NAT
ssh -p 2222 ansible@localhost

# Check running services
docker ps
sudo systemctl status docker
```

### 3. Storage Testing

```bash
# Check disk usage
df -h

# Test mount points
ls -la /mnt/

# Check for any storage-related services
docker ps | grep -E "(samba|storage|file)"
```

### 4. Network Testing

```bash
# Test connectivity from VM
ping google.com
nslookup google.com

# Check listening ports
ss -tlnp

# Test web services
curl -I http://localhost:80
curl -I http://localhost:9000
```

## 🐛 Troubleshooting

### SSH Connection Issues (NAT Networking)

When using NAT networking, SSH connection timeouts are common. Here's a comprehensive troubleshooting guide:

#### 1. Verify VM Network Configuration

```bash
# Check VM network settings
VBoxManage showvminfo "ragna-nas-test" | grep -i nic

# Check port forwarding rules
VBoxManage showvminfo "ragna-nas-test" | grep -i "NIC 1 Rule"
```

#### 2. Configure NAT Port Forwarding

If port forwarding isn't set up properly:

```bash
# Stop the VM first
VBoxManage controlvm "ragna-nas-test" poweroff

# Add SSH port forwarding (host port 2222 -> guest port 22)
VBoxManage modifyvm "ragna-nas-test" --natpf1 "ssh,tcp,,2222,,22"

# Add additional ports for services
VBoxManage modifyvm "ragna-nas-test" --natpf1 "zimaos,tcp,,8080,,80"
VBoxManage modifyvm "ragna-nas-test" --natpf1 "portainer,tcp,,9000,,9000"

# Start the VM
VBoxManage startvm "ragna-nas-test" --type headless
```

#### 3. Use Correct NAT Connection Method

```bash
# CORRECT: Connect via port forwarding
ssh -p 2222 ubuntu@localhost

# INCORRECT: Don't use the actual VM IP with NAT
# ssh ubuntu@<actual-ip>  # This won't work with NAT
```

#### 4. Check VM Status and IP

```bash
# Check if VM is running
VBoxManage list runningvms

# Get VM IP (this might be a NAT internal IP like 10.0.2.15)
VBoxManage guestproperty get "ragna-nas-test" "/VirtualBox/GuestInfo/Net/0/V4/IP"

# Alternative: Connect via VirtualBox console to check
VBoxManage guestcontrol "ragna-nas-test" run --exe "/bin/ip" --username ubuntu --password ubuntu -- addr show
```

#### 5. Verify SSH Service in VM

Connect to the VM console to check SSH status:

```bash
# Connect to VM console via VirtualBox GUI or:
VBoxManage guestcontrol "ragna-nas-test" run --exe "/bin/systemctl" --username ubuntu --password ubuntu -- status ssh
```

If you can access the VM console directly:

```bash
# Check SSH service status
sudo systemctl status ssh
sudo systemctl status sshd

# Check if SSH is listening
sudo ss -tlnp | grep :22

# Check firewall
sudo ufw status

# Restart SSH if needed
sudo systemctl restart ssh
sudo systemctl enable ssh
```

#### 6. Check Firewall Settings

```bash
# In the VM console, check firewall
sudo ufw status

# If firewall is blocking SSH, allow it
sudo ufw allow ssh
sudo ufw allow 22/tcp

# Restart firewall
sudo ufw reload
```

#### 7. Complete NAT Setup Script

Use this complete setup script if you're having persistent issues:

```bash
# Complete NAT setup script
VM_NAME="ragna-nas-test"

# Stop VM
VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null || true

# Configure NAT with port forwarding
VBoxManage modifyvm "$VM_NAME" --nic1 nat
VBoxManage modifyvm "$VM_NAME" --natpf1 "ssh,tcp,,2222,,22"
VBoxManage modifyvm "$VM_NAME" --natpf1 "zimaos,tcp,,8080,,80"
VBoxManage modifyvm "$VM_NAME" --natpf1 "portainer,tcp,,9000,,9000"

# Start VM
VBoxManage startvm "$VM_NAME" --type headless

# Wait for boot (30 seconds)
echo "Waiting for VM to boot..."
sleep 30

# Test SSH connection
echo "Testing SSH connection..."
ssh -p 2222 -o ConnectTimeout=10 ubuntu@localhost
```

#### 8. Alternative: Switch to Bridged Networking

If NAT continues to cause issues, switch to bridged networking:

```bash
# Stop VM
VBoxManage controlvm "ragna-nas-test" poweroff

# Remove NAT port forwarding rules
VBoxManage modifyvm "ragna-nas-test" --natpf1 delete "ssh"
VBoxManage modifyvm "ragna-nas-test" --natpf1 delete "zimaos"
VBoxManage modifyvm "ragna-nas-test" --natpf1 delete "portainer"

# Switch to bridged networking (replace eth0 with your host interface)
VBoxManage modifyvm "ragna-nas-test" --nic1 bridged --bridgeadapter1 "eth0"

# Start VM
VBoxManage startvm "ragna-nas-test" --type headless

# Wait for boot, then find the VM's IP
sleep 30
VBoxManage guestproperty get "ragna-nas-test" "/VirtualBox/GuestInfo/Net/0/V4/IP"

# Now you can SSH directly to the VM's IP
ssh ubuntu@<vm-ip-address>
```

#### 9. Quick Connection Test

Test the connection step by step:

```bash
# 1. Check if port is listening on host
netstat -tlnp | grep :2222
# or
ss -tlnp | grep :2222

# 2. Test basic connectivity
telnet localhost 2222

# 3. Try SSH with verbose output
ssh -p 2222 -v ubuntu@localhost

# 4. Test without host key checking
ssh -p 2222 -o StrictHostKeyChecking=no ubuntu@localhost
```

#### 10. Most Common Issues and Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Port forwarding not configured** | Connection timeout | Add port forwarding rules (step 2) |
| **Wrong connection method** | Connection refused | Use `ssh -p 2222 ubuntu@localhost` not VM IP |
| **VM not fully booted** | Connection timeout | Wait longer or check VM console |
| **SSH service not running** | Connection refused | Access VM console and start SSH service |
| **Firewall blocking** | Connection timeout | Allow SSH through firewall |
| **Host key issues** | Host key verification failed | Use `-o StrictHostKeyChecking=no` or delete known_hosts entry |

#### 11. Reset VM Network Interface

If the VM has network issues:

```bash
# In VM console, reset network
sudo netplan apply
sudo systemctl restart systemd-networkd

# Or restart networking
sudo systemctl restart networking

# Check network status
ip addr show
ip route show
```

### Common VirtualBox Issues

**VM Won't Start:**
```bash
# Check VM status
VBoxManage list runningvms

# Check for resource conflicts
VBoxManage showvminfo "ragna-nas-test"

# Reset VM if needed
VBoxManage controlvm "ragna-nas-test" poweroff
VBoxManage startvm "ragna-nas-test" --type headless
```

**General Network Connectivity Issues:**
```bash
# Check network adapter
VBoxManage showvminfo "ragna-nas-test" | grep NIC

# Reset network adapter
VBoxManage modifyvm "ragna-nas-test" --nic1 none
VBoxManage modifyvm "ragna-nas-test" --nic1 bridged --bridgeadapter1 "eth0"
```

**Storage Issues:**
```bash
# Check attached storage
VBoxManage showvminfo "ragna-nas-test" | grep "Storage"

# Detach and reattach disk if needed
VBoxManage storageattach "ragna-nas-test" --storagectl "SATA" --port 1 --device 0 --type none
VBoxManage storageattach "ragna-nas-test" --storagectl "SATA" --port 1 --device 0 --type hdd --medium ~/VirtualBox\ VMs/ragna-nas-test/storage/data-disk-1.vdi
```

### Ansible Issues

**Connection Problems:**
```bash
# Test basic connectivity
ansible all -i inventories/virtualbox/hosts.ini -m ping -vvv

# Check SSH configuration
ssh -v ansible@192.168.1.150
```

**Permission Issues:**
```bash
# Verify ansible user setup
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "whoami"
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "sudo whoami"
```

**Service Deployment Issues:**
```bash
# Check Docker installation
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "docker --version"

# Check available disk space
ansible all -i inventories/virtualbox/hosts.ini -m shell -a "df -h"
```

## 📚 Testing Scenarios

### 1. Basic Functionality Test
- Deploy base system with Docker
- Verify web interfaces are accessible
- Test SSH connectivity

### 2. Storage Configuration Test
- Test with different storage layouts
- Verify mount points and permissions
- Test storage-related containers

### 3. Network Configuration Test
- Test different IP configurations
- Verify service discovery
- Test port accessibility

### 4. Recovery Testing
- Simulate failures and recovery
- Test backup and restore procedures
- Verify service resilience

## 🧹 Cleanup

### Stop and Remove Test VM

```bash
# Stop VM
VBoxManage controlvm "ragna-nas-test" poweroff

# Remove VM and disks
VBoxManage unregistervm "ragna-nas-test" --delete

# Clean up storage files
rm -rf ~/VirtualBox\ VMs/ragna-nas-test/
```

### Reset for New Testing

```bash
# Clone fresh VM for new test
VBoxManage clonevm "ubuntu-server-base" --name "ragna-nas-test-2" --register

# Or restore from snapshot
VBoxManage snapshot "ragna-nas-test" restore "initial-state"
```

## 🔗 Integration with Vagrant

This manual testing approach complements the automated Vagrant testing:

- **Manual VirtualBox**: Detailed testing, debugging, custom configurations
- **Vagrant**: Automated testing, CI/CD integration, standardized environments

Both approaches ensure comprehensive validation before hardware deployment.

## 📝 Best Practices

1. **Snapshot Before Testing**: Take VM snapshots before major changes
2. **Document Issues**: Keep notes on problems and solutions
3. **Test Incrementally**: Deploy components step by step
4. **Monitor Resources**: Watch CPU, memory, and disk usage
5. **Clean Environments**: Start with fresh VMs for each major test
6. **Version Control**: Keep different VM configurations for different test scenarios

This manual testing approach provides maximum flexibility for debugging and experimentation while maintaining compatibility with the production deployment workflow.