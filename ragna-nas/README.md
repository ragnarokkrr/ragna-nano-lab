# GMKTec G9 NAS – Manual Installation & Ansible Remote Setup

This repository provides a complete setup guide and Ansible playbook run preparation for turning your GMKTec NucBox G9 into a fully functional NAS using Ubuntu Server and remote provisioning via Ansible.

---

## 🧱 Manual Installation Steps

### 1. Install Ubuntu Server
- Create a bootable USB with [Ubuntu Server ISO](https://ubuntu.com/download/server).
- Boot the GMKTec G9 from the USB and install Ubuntu Server.
- Configure a user account and optionally assign a static IP.

### 2. Install Lubuntu GUI (Optional)
```bash
sudo apt update && sudo apt install tasksel -y
sudo tasksel install lubuntu-desktop
sudo systemctl set-default multi-user.target  # Prevent GUI auto-start
```

To start GUI manually:
```bash
startx
```

### 3. Enable SSH
```bash
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
```

### 4. Set Up SSH Key Access for Ansible
On the Ansible controller:
```bash
ssh-keygen -t ed25519 -C "ansible@nas"
ssh-copy-id user@nas_ip_address
```

### 5. Install Python
```bash
sudo apt install python3 -y
sudo apt install python3-pip -y
```

### 6. Configure Static IP (if needed)
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Sample:
```yaml
network:
  version: 2
  ethernets:
    enp2s0:
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

Apply:
```bash
sudo netplan apply
```

## 📌 Notes

- Ensure the Ansible controller can SSH into the NAS with the configured user and key.
- Roles are modular—add or remove services as needed.
- ZFS support assumes a disk or partition is available for the ZFS pool (`/dev/sdX`).

---

## 🧩 License

MIT License – Use freely, improve and share!
