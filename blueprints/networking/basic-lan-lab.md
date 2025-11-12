# Basic LAN Lab Environment

## Overview

**Purpose:** A foundational local area network (LAN) laboratory for learning network fundamentals, testing configurations, and developing network applications.

**Use Cases:**
- Network protocol analysis and testing
- DHCP, DNS, and routing configurations
- Network troubleshooting practice
- Application development and testing in isolated network

## Architecture

### System Topology

```
Internet
    |
[Router/Gateway] (192.168.1.1)
    |
    |----[Switch]
             |
             |----[Server] (192.168.1.10)
             |----[Workstation 1] (192.168.1.100)
             |----[Workstation 2] (192.168.1.101)
             |----[Workstation 3] (192.168.1.102)
```

### Components

| Component | Role | Specifications |
|-----------|------|----------------|
| Router/Gateway | Internet connectivity and NAT | 1 GHz CPU, 512 MB RAM, 2x GigE ports |
| Switch | Layer 2 connectivity | 8-port Gigabit Switch |
| Server | DHCP, DNS, File Server | 4 cores, 8 GB RAM, 100 GB storage |
| Workstations | Client machines | 2 cores, 4 GB RAM, 50 GB storage each |

## Requirements

### Hardware Requirements

- **Router:** Consumer-grade router or dedicated device with OpenWRT/pfSense capability
- **Switch:** 8+ port Gigabit Ethernet switch
- **Server:** Physical or VM with 4 cores, 8 GB RAM, 100 GB storage
- **Workstations:** 3+ physical or virtual machines with 2 cores, 4 GB RAM each
- **Cables:** CAT6 Ethernet cables

### Software Requirements

- **Router OS:** OpenWRT, pfSense, or OPNsense
- **Server OS:** Ubuntu Server 22.04 LTS or CentOS Stream 9
- **Workstation OS:** Ubuntu Desktop 22.04 LTS or similar
- **Required Packages:**
  - isc-dhcp-server
  - bind9
  - iptables
  - tcpdump
  - wireshark

## Setup Instructions

### 1. Environment Preparation

```bash
# Update all systems
sudo apt update && sudo apt upgrade -y
```

### 2. Router Configuration

```bash
# Configure WAN interface for internet access
# Configure LAN interface: 192.168.1.1/24
# Enable NAT/masquerading
sudo iptables -t nat -A POSTROUTING -o wan0 -j MASQUERADE
sudo iptables -A FORWARD -i lan0 -o wan0 -j ACCEPT
sudo iptables -A FORWARD -i wan0 -o lan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

### 3. Server Setup - DHCP

```bash
# Install DHCP server
sudo apt install isc-dhcp-server -y

# Configure DHCP
sudo tee /etc/dhcp/dhcpd.conf << EOF
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.10;
    option domain-name "lab.local";
}
EOF

# Start DHCP service
sudo systemctl enable isc-dhcp-server
sudo systemctl start isc-dhcp-server
```

### 4. Server Setup - DNS

```bash
# Install DNS server
sudo apt install bind9 -y

# Configure DNS forwarders
sudo tee -a /etc/bind/named.conf.options << EOF
forwarders {
    8.8.8.8;
    8.8.4.4;
};
EOF

# Restart DNS service
sudo systemctl restart bind9
```

## Validation

### Test Procedures

1. **Test DHCP Assignment:**
   ```bash
   # On workstation
   sudo dhclient -r && sudo dhclient
   ip addr show
   ```
   Expected output: IP address in range 192.168.1.100-200

2. **Test DNS Resolution:**
   ```bash
   # On workstation
   nslookup google.com
   dig example.com
   ```
   Expected output: Successful DNS resolution

3. **Test Internet Connectivity:**
   ```bash
   # On workstation
   ping -c 4 8.8.8.8
   ping -c 4 google.com
   ```
   Expected output: 0% packet loss

4. **Test Internal Connectivity:**
   ```bash
   # From workstation to server
   ping -c 4 192.168.1.10
   # Between workstations
   ping -c 4 192.168.1.101
   ```
   Expected output: Successful ping responses

## Usage

### Common Operations

```bash
# Check DHCP leases
sudo cat /var/lib/dhcp/dhcpd.leases

# Monitor network traffic
sudo tcpdump -i eth0

# View routing table
ip route show

# Check DNS queries
sudo journalctl -u bind9 -f
```

### Monitoring

```bash
# Monitor bandwidth usage
sudo iftop

# Network statistics
netstat -i
ss -s
```

## Troubleshooting

### Issue 1: Workstations not getting DHCP addresses

**Symptom:** Clients remain with APIPA addresses (169.254.x.x) or no IP

**Solution:** 
- Check DHCP server status: `sudo systemctl status isc-dhcp-server`
- Verify network cable connections
- Check firewall rules allowing DHCP (ports 67/68)
- Review DHCP logs: `sudo journalctl -u isc-dhcp-server`

### Issue 2: No internet connectivity from workstations

**Symptom:** Can ping local network but not external addresses

**Solution:**
- Verify NAT rules on router: `sudo iptables -t nat -L`
- Check default gateway on clients: `ip route`
- Verify DNS server configuration
- Test router's internet connection

### Issue 3: DNS resolution failures

**Symptom:** Cannot resolve domain names

**Solution:**
- Check BIND9 status: `sudo systemctl status bind9`
- Verify DNS server in DHCP configuration
- Test with alternative DNS: `nslookup google.com 8.8.8.8`
- Check forwarder configuration in `/etc/bind/named.conf.options`

## Maintenance

### Regular Tasks

- **Weekly:** Review DHCP leases and clean expired entries
- **Monthly:** Update system packages and security patches
- **Quarterly:** Review and update firewall rules

### Backup and Recovery

```bash
# Backup configurations
sudo tar -czf /backup/network-config-$(date +%Y%m%d).tar.gz \
    /etc/dhcp/ \
    /etc/bind/ \
    /etc/network/

# Restore from backup
sudo tar -xzf /backup/network-config-YYYYMMDD.tar.gz -C /
```

## References

- [Ubuntu Server Guide - Networking](https://ubuntu.com/server/docs/network-introduction)
- [ISC DHCP Documentation](https://www.isc.org/dhcp/)
- [BIND9 Documentation](https://bind9.readthedocs.io/)
- [iptables Tutorial](https://www.netfilter.org/documentation/)

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-12 | Initial version | Systems Lab Team |
