# 🧰 ZimaOS + Homelab Ansible Automation

This project is a modular, scalable **Ansible-based automation toolkit** designed to install and manage [ZimaOS (CasaOS)](https://casaos.io) and additional homelab services on systems like the **GMKTec NucBox G9**.

---

## 🚀 Features

- ✅ **Modular roles**: Docker, CasaOS, Portainer, Samba, ZFS, Netplan, Firewall
- 🏷 **Tag-based execution**: Run only the components you need
- 🌍 **Multi-environment inventories**: Support for `g9`, `homelab`, etc.
- 🔁 **Extensible**: Add your own roles and playbooks easily
- 📦 **App-ready**: Built-in Jellyfin app role to demonstrate extending services

---

## 🗂️ Project Structure

```
zimaos-ansible/
├── inventories/
│   ├── g9/
│   └── homelab/
├── playbooks/
│   ├── site.yml
│   ├── deploy-apps.yml
│   └── harden-system.yml
├── roles/
│   ├── docker/
│   ├── zimaos/
│   ├── portainer/
│   ├── samba/
│   ├── zfs/
│   ├── netplan/
│   ├── firewall/
│   └── jellyfin/
├── group_vars/
├── vars/
├── templates/
└── files/
```

---

## 📋 Prerequisites

- ✅ Ubuntu 20.04/22.04 installed on GMKTec NucBox G9 or similar x86_64 system
- ✅ SSH access with key-based auth (`ansible_ssh_private_key_file`)
- ✅ Ansible 2.10+ installed on control machine

Install Ansible:
```bash
sudo apt install ansible
```

---

## 🔧 Configuration

### 1. Edit your **inventory**

`inventories/g9/hosts.ini`
```ini
[g9]
192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 2. Customize your **group_vars**

`inventories/g9/group_vars/all.yml` (or use `group_vars/all.yml`)
```yaml
enable_zfs: true
zfs_disk_device: /dev/sdb
...
```

---

## 📦 How to Run

### Full system setup:
```bash
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml
```

### Selective roles using tags:
```bash
ansible-playbook -i inventories/g9/hosts.ini playbooks/site.yml --tags docker,samba
```

### App deployment:
```bash
ansible-playbook -i inventories/g9/hosts.ini playbooks/deploy-apps.yml --tags jellyfin
```

---

## 🌐 Default Access Points

| Service         | URL/Path                           |
|-----------------|------------------------------------|
| ZimaOS Web UI   | `http://<your-ip>`                 |
| Portainer       | `http://<your-ip>:9000`            |
| Samba Share     | `\<your-ip>\Public`               |
| Jellyfin        | `http://<your-ip>:8096` (example)  |

---

## ➕ Adding a New Role

```bash
ansible-galaxy init roles/<your-role-name>
```

Add it to a playbook like `deploy-apps.yml`.

---

## 📄 License

MIT — use freely and customize.

## 🙋 Need Help?

Open a GitHub issue or contact the project maintainer.