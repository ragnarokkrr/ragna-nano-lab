# PVC Services - ProxMox Virtualized Services

This directory contains configuration and automation for virtualized services deployed on ProxMox VE infrastructure.

## 🎯 Overview

PVC Services provides containerized and virtualized service orchestration on top of ProxMox virtualization platform, enabling:

- **Container Orchestration**: Kubernetes and Docker Swarm deployments
- **Service Management**: Automated provisioning and scaling
- **Persistent Storage**: PVC (Persistent Volume Claims) management
- **High Availability**: Multi-node service resilience
- **Resource Management**: CPU, memory, and storage allocation

## 🏗️ Architecture

### Service Categories

#### Core Infrastructure Services
- **Container Registry**: Private Docker registry for custom images
- **Service Mesh**: Istio/Linkerd for service communication
- **Storage Management**: Ceph/Longhorn for distributed storage
- **Monitoring Stack**: Prometheus, Grafana, AlertManager

#### Application Services  
- **Web Services**: Nginx, Apache, reverse proxies
- **Database Services**: PostgreSQL, MySQL, Redis clusters
- **Message Queues**: RabbitMQ, Apache Kafka
- **CI/CD Services**: Jenkins, GitLab Runner, Tekton

#### Development Services
- **Code Repositories**: GitLab, Gitea instances
- **Testing Infrastructure**: Selenium grids, test runners
- **Documentation**: Wiki, documentation generators
- **Development Tools**: IDE servers, code analysis tools

## 📋 Prerequisites

### ProxMox Infrastructure
- **ProxMox VE**: Version 7.0+ cluster
- **Networking**: VLAN configuration for `ragna-proxmox` segment
- **Storage**: Shared storage (NFS, Ceph, or ZFS)
- **Resources**: Adequate CPU, memory, and storage allocation

### Kubernetes Requirements
- **Node Configuration**: Minimum 3 nodes for HA
- **Network Plugin**: Calico, Flannel, or Cilium
- **Storage Classes**: Dynamic provisioning support
- **Load Balancer**: MetalLB or external load balancer
