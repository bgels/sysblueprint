# Container Cluster Lab Environment

## Overview

**Purpose:** A Kubernetes-based container orchestration laboratory for learning container management, microservices deployment, and cloud-native application development.

**Use Cases:**
- Kubernetes administration and operation
- Container orchestration practice
- CI/CD pipeline development
- Microservices architecture testing
- DevOps training and experimentation

## Architecture

### System Topology

```
[Load Balancer] (192.168.2.10)
        |
        |----[Master Node 1] (192.168.2.11)
        |----[Master Node 2] (192.168.2.12)
        |----[Master Node 3] (192.168.2.13)
        |
        |----[Worker Node 1] (192.168.2.21)
        |----[Worker Node 2] (192.168.2.22)
        |----[Worker Node 3] (192.168.2.23)
        |
        |----[Storage Node] (192.168.2.30)
```

### Components

| Component | Role | Specifications |
|-----------|------|----------------|
| Load Balancer | API server load balancing | 2 cores, 4 GB RAM, 50 GB storage |
| Master Nodes (3) | Kubernetes control plane | 4 cores, 8 GB RAM, 100 GB storage each |
| Worker Nodes (3) | Container workload execution | 8 cores, 16 GB RAM, 200 GB storage each |
| Storage Node | Persistent volume storage | 4 cores, 8 GB RAM, 500 GB storage |

## Requirements

### Hardware Requirements

- **Total:** 7 nodes (can be VMs)
- **CPU:** Minimum 50 cores total
- **Memory:** Minimum 100 GB RAM total
- **Storage:** Minimum 1.5 TB total
- **Network:** 10 GigE recommended, 1 GigE minimum

### Software Requirements

- **Operating System:** Ubuntu 22.04 LTS (all nodes)
- **Container Runtime:** containerd 1.6+
- **Kubernetes:** v1.28 or later
- **Required Tools:**
  - kubeadm
  - kubelet
  - kubectl
  - helm
  - etcd
- **Optional Tools:**
  - Prometheus & Grafana for monitoring
  - ArgoCD for GitOps
  - Istio for service mesh

## Setup Instructions

### 1. Environment Preparation

```bash
# On all nodes
sudo apt update && sudo apt upgrade -y

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

### 2. Install Container Runtime

```bash
# On all nodes
sudo apt install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Enable systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
```

### 3. Install Kubernetes Components

```bash
# On all nodes
sudo apt install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 4. Initialize First Master Node

```bash
# On master node 1
sudo kubeadm init --control-plane-endpoint="192.168.2.10:6443" \
    --upload-certs \
    --pod-network-cidr=10.244.0.0/16

# Setup kubectl for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 5. Install Network Plugin

```bash
# Install Calico CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### 6. Join Additional Master Nodes

```bash
# On master nodes 2 and 3
# Use the join command from kubeadm init output
sudo kubeadm join 192.168.2.10:6443 --token <token> \
    --discovery-token-ca-cert-hash sha256:<hash> \
    --control-plane --certificate-key <key>
```

### 7. Join Worker Nodes

```bash
# On worker nodes
sudo kubeadm join 192.168.2.10:6443 --token <token> \
    --discovery-token-ca-cert-hash sha256:<hash>
```

## Validation

### Test Procedures

1. **Test Cluster Status:**
   ```bash
   kubectl get nodes
   kubectl cluster-info
   ```
   Expected output: All nodes in Ready state

2. **Test Pod Deployment:**
   ```bash
   kubectl create deployment nginx --image=nginx
   kubectl expose deployment nginx --port=80 --type=NodePort
   kubectl get pods,svc
   ```
   Expected output: Pod running, service created

3. **Test DNS Resolution:**
   ```bash
   kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
   ```
   Expected output: Successful DNS resolution

4. **Test Cross-Node Communication:**
   ```bash
   kubectl scale deployment nginx --replicas=6
   kubectl get pods -o wide
   ```
   Expected output: Pods distributed across worker nodes

## Usage

### Common Operations

```bash
# Deploy an application
kubectl apply -f deployment.yaml

# Scale deployment
kubectl scale deployment myapp --replicas=5

# Update image
kubectl set image deployment/myapp myapp=myapp:v2

# View logs
kubectl logs -f deployment/myapp

# Execute commands in pod
kubectl exec -it podname -- /bin/bash

# Port forwarding
kubectl port-forward service/myapp 8080:80
```

### Monitoring

```bash
# Resource usage
kubectl top nodes
kubectl top pods

# Cluster events
kubectl get events --sort-by='.lastTimestamp'

# Component status
kubectl get componentstatuses
```

## Troubleshooting

### Issue 1: Nodes in NotReady state

**Symptom:** Nodes show NotReady in `kubectl get nodes`

**Solution:**
- Check kubelet status: `sudo systemctl status kubelet`
- Review kubelet logs: `sudo journalctl -u kubelet -f`
- Verify CNI plugin installation: `kubectl get pods -n kube-system`
- Check network connectivity between nodes

### Issue 2: Pods stuck in Pending state

**Symptom:** Pods remain in Pending state indefinitely

**Solution:**
- Check pod events: `kubectl describe pod <podname>`
- Verify resource availability: `kubectl top nodes`
- Check for taints: `kubectl describe nodes | grep -i taint`
- Verify storage class if PVC is used

### Issue 3: DNS resolution failures in pods

**Symptom:** Pods cannot resolve DNS names

**Solution:**
- Check CoreDNS status: `kubectl get pods -n kube-system -l k8s-app=kube-dns`
- Verify DNS service: `kubectl get svc -n kube-system`
- Test DNS from node: `nslookup kubernetes.default.svc.cluster.local 10.96.0.10`
- Review CoreDNS logs: `kubectl logs -n kube-system -l k8s-app=kube-dns`

## Maintenance

### Regular Tasks

- **Daily:** Monitor cluster health and resource usage
- **Weekly:** Review pod logs for errors and warnings
- **Monthly:** Update Kubernetes components and node OS
- **Quarterly:** Review and optimize resource allocations

### Backup and Recovery

```bash
# Backup etcd
ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-snapshot.db \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key

# Restore etcd
ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd-snapshot.db
```

## References

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubeadm Setup Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
- [Calico Documentation](https://docs.projectcalico.org/)
- [Container Runtime Interface](https://kubernetes.io/docs/concepts/architecture/cri/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-12 | Initial version | Systems Lab Team |
