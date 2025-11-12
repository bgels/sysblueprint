# Distributed Storage Lab Environment

## Overview

**Purpose:** A Ceph-based distributed storage laboratory for learning software-defined storage, object storage, and high-availability storage architectures.

**Use Cases:**
- Distributed storage system administration
- Object, block, and file storage testing
- Storage performance analysis
- Disaster recovery and replication testing
- Storage cluster monitoring and troubleshooting

## Architecture

### System Topology

```
[Management Node] (192.168.3.10)
        |
        |----[Monitor Node 1] (192.168.3.11)
        |----[Monitor Node 2] (192.168.3.12)
        |----[Monitor Node 3] (192.168.3.13)
        |
        |----[OSD Node 1] (192.168.3.21) - 4 disks
        |----[OSD Node 2] (192.168.3.22) - 4 disks
        |----[OSD Node 3] (192.168.3.23) - 4 disks
        |----[OSD Node 4] (192.168.3.24) - 4 disks
        |
        |----[Gateway Node 1] (192.168.3.31) - RGW/MDS
        |----[Gateway Node 2] (192.168.3.32) - RGW/MDS
```

### Components

| Component | Role | Specifications |
|-----------|------|----------------|
| Management Node | Deployment and admin | 4 cores, 8 GB RAM, 100 GB storage |
| Monitor Nodes (3) | Cluster state and consensus | 2 cores, 4 GB RAM, 50 GB storage each |
| OSD Nodes (4) | Object storage daemons | 8 cores, 16 GB RAM, 100 GB OS + 4x1TB data disks |
| Gateway Nodes (2) | RGW/MDS services | 4 cores, 8 GB RAM, 100 GB storage each |

## Requirements

### Hardware Requirements

- **Total:** 10 nodes (can be VMs for testing)
- **CPU:** Minimum 60 cores total
- **Memory:** Minimum 120 GB RAM total
- **Storage:** 16x 1TB data disks + OS disks
- **Network:** 10 GigE highly recommended, dedicated storage network

### Software Requirements

- **Operating System:** Ubuntu 22.04 LTS or Rocky Linux 9
- **Ceph Version:** Quincy (v17) or later
- **Required Packages:**
  - cephadm
  - podman or docker
  - python3
  - lvm2
- **Optional Tools:**
  - ceph-dashboard
  - prometheus
  - grafana

## Setup Instructions

### 1. Environment Preparation

```bash
# On all nodes
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y python3 python3-pip lvm2 chrony

# Configure NTP
sudo systemctl enable chronyd
sudo systemctl start chronyd

# Configure hostnames and /etc/hosts
sudo hostnamectl set-hostname <nodename>

# Add all nodes to /etc/hosts
cat <<EOF | sudo tee -a /etc/hosts
192.168.3.10 mgmt01
192.168.3.11 mon01
192.168.3.12 mon02
192.168.3.13 mon03
192.168.3.21 osd01
192.168.3.22 osd02
192.168.3.23 osd03
192.168.3.24 osd04
192.168.3.31 gw01
192.168.3.32 gw02
EOF
```

### 2. Install Cephadm

```bash
# On management node
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod +x cephadm
sudo ./cephadm add-repo --release quincy
sudo ./cephadm install
```

### 3. Bootstrap Cluster

```bash
# On management node
sudo cephadm bootstrap --mon-ip 192.168.3.10 \
    --cluster-network 192.168.3.0/24 \
    --initial-dashboard-user admin \
    --initial-dashboard-password changeme

# Enable Ceph CLI
sudo cephadm shell
```

### 4. Add Monitor Nodes

```bash
# Copy SSH key to all nodes
ssh-copy-id -f -i /etc/ceph/ceph.pub root@mon01
ssh-copy-id -f -i /etc/ceph/ceph.pub root@mon02
ssh-copy-id -f -i /etc/ceph/ceph.pub root@mon03

# Add hosts
ceph orch host add mon01 192.168.3.11
ceph orch host add mon02 192.168.3.12
ceph orch host add mon03 192.168.3.13

# Add monitor daemons
ceph orch apply mon --placement="mon01,mon02,mon03"
```

### 5. Add OSD Nodes

```bash
# Add OSD hosts
ceph orch host add osd01 192.168.3.21
ceph orch host add osd02 192.168.3.22
ceph orch host add osd03 192.168.3.23
ceph orch host add osd04 192.168.3.24

# List available devices
ceph orch device ls

# Add all available devices as OSDs
ceph orch apply osd --all-available-devices

# Or add specific devices
ceph orch daemon add osd osd01:/dev/sdb
```

### 6. Configure Gateway Services

```bash
# Deploy RGW (Object Gateway)
ceph orch apply rgw default --placement="2 gw01 gw02" --port=8080

# Deploy MDS (Metadata Server for CephFS)
ceph orch apply mds cephfs --placement="2 gw01 gw02"

# Create CephFS
ceph fs volume create cephfs
```

## Validation

### Test Procedures

1. **Test Cluster Health:**
   ```bash
   ceph status
   ceph health detail
   ```
   Expected output: HEALTH_OK

2. **Test OSD Status:**
   ```bash
   ceph osd stat
   ceph osd tree
   ceph osd df
   ```
   Expected output: All OSDs up and in

3. **Test Block Storage:**
   ```bash
   # Create pool and RBD image
   ceph osd pool create rbd 32 32
   rbd create test-image --size 10G --pool rbd
   
   # Map and use
   sudo rbd map rbd/test-image
   sudo mkfs.ext4 /dev/rbd0
   ```
   Expected output: Successfully created and formatted

4. **Test Object Storage:**
   ```bash
   # Create S3 user
   radosgw-admin user create --uid=testuser --display-name="Test User"
   
   # Test with s3cmd
   s3cmd --host=http://gw01:8080 ls
   ```
   Expected output: Successful S3 connection

5. **Test CephFS:**
   ```bash
   # Mount CephFS
   sudo mkdir /mnt/cephfs
   sudo mount -t ceph mon01:6789:/ /mnt/cephfs -o name=admin,secret=$(sudo ceph auth get-key client.admin)
   
   # Write test
   sudo dd if=/dev/zero of=/mnt/cephfs/testfile bs=1M count=100
   ```
   Expected output: Successful mount and write

## Usage

### Common Operations

```bash
# Check cluster status
ceph -s
ceph health detail

# Monitor cluster activity
ceph -w

# Check pool information
ceph osd pool ls detail
ceph osd pool stats

# Create storage pool
ceph osd pool create mypool 128 128

# Adjust pool size (replication)
ceph osd pool set mypool size 3
ceph osd pool set mypool min_size 2

# Check OSD usage
ceph osd df tree

# Manage OSDs
ceph osd out osd.5
ceph osd in osd.5
```

### Monitoring

```bash
# Performance statistics
ceph osd perf
ceph osd pool stats

# I/O operations
rados bench -p rbd 30 write
rados bench -p rbd 30 seq

# Dashboard access
# https://mgmt01:8443
```

## Troubleshooting

### Issue 1: Cluster showing HEALTH_WARN

**Symptom:** `ceph status` shows warnings

**Solution:**
- Review warnings: `ceph health detail`
- Common issues: clock skew, PG imbalance, low disk space
- Check logs: `ceph log last 50`
- For clock skew: ensure NTP is synchronized on all nodes

### Issue 2: OSDs not coming up

**Symptom:** OSDs marked as down

**Solution:**
- Check OSD status: `ceph osd tree`
- Review OSD logs: `journalctl -u ceph-osd@X -f`
- Verify disk health: `smartctl -a /dev/sdX`
- Check network connectivity between nodes
- Restart OSD: `systemctl restart ceph-osd@X`

### Issue 3: Slow performance

**Symptom:** Poor read/write performance

**Solution:**
- Check network latency between nodes
- Review OSD performance: `ceph osd perf`
- Check for slow OSDs: `ceph health detail`
- Monitor disk I/O: `iostat -x 1`
- Verify no OSDs are full: `ceph osd df`
- Check PG distribution: `ceph pg dump`

### Issue 4: Unable to mount CephFS

**Symptom:** Mount command fails or hangs

**Solution:**
- Verify MDS is active: `ceph fs status`
- Check monitor connectivity: `ping mon01`
- Verify authentication key: `ceph auth get client.admin`
- Review firewall rules for ports 6789 and 6800-7300
- Check MDS logs: `journalctl -u ceph-mds -f`

## Maintenance

### Regular Tasks

- **Daily:** Review cluster health and capacity
- **Weekly:** Check and balance PG distribution
- **Monthly:** Update Ceph software and firmware
- **Quarterly:** Test backup and recovery procedures

### Backup and Recovery

```bash
# Backup configuration
ceph config dump > /backup/ceph-config.txt
ceph osd tree > /backup/ceph-osd-tree.txt

# Export RBD images
rbd export rbd/my-image /backup/my-image.img

# Backup CephFS metadata
cephfs-data-scan init
cephfs-journal-tool journal export backup.bin
```

## References

- [Ceph Documentation](https://docs.ceph.com/)
- [Cephadm Installation](https://docs.ceph.com/en/latest/cephadm/)
- [Ceph Architecture](https://docs.ceph.com/en/latest/architecture/)
- [RADOS Paper](https://ceph.io/assets/pdfs/weil-rados-pdsw07.pdf)
- [Ceph Performance Tuning](https://docs.ceph.com/en/latest/rados/configuration/)

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-12 | Initial version | Systems Lab Team |
