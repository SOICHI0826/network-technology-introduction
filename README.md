# Network Technology Introduction

This repository provides network simulation environments for studying various network technologies and configurations using **tinet** (Docker-based network simulator).

## Overview

Create complex network topologies including routers, switches, load balancers, firewalls, DNS servers, and web servers for hands-on learning and testing of network protocols and configurations.

## Prerequisites

### Required Software

- **macOS** (tested on macOS 13.3+)
- **Multipass** - For running Ubuntu VM
- **Git** - For version control

### System Requirements

- **CPU**: 2+ cores (4+ recommended)
- **RAM**: 4GB+ available
- **Disk**: 10GB+ free space
- **Architecture**: Apple Silicon (ARM64) or Intel (x86_64)

## Installation

### Step 1: Install Multipass

```bash
brew install multipass
```

Or download from: https://multipass.run/

### Step 2: Clone This Repository

```bash
git clone https://github.com/SOICHI0826/network-technology-introduction.git
cd network-technology-introduction
```

### Step 3: Create Ubuntu VM

Create an Ubuntu instance with this repository mounted:

```bash
multipass launch 22.04 --cpus 2 --memory 4G --name UBUNTU --mount $(pwd):/mnt/c/tinet
```

**Note**: Ubuntu 22.04 is recommended. Ubuntu 20.04 has reached end-of-life and may have compatibility issues.

### Step 4: Enter the VM

```bash
multipass shell UBUNTU
```

### Step 5: Run Setup Script

Inside the Ubuntu VM, run the setup script as root:

```bash
sudo bash /mnt/c/tinet/setup_mac.sh
```

This script will:
1. Configure DNS nameservers (8.8.8.8, 1.1.1.1)
2. Update Ubuntu packages
3. Install Docker and required components
4. Install tinet binary

### Step 6: Verify Installation

After setup completes, verify the installation:

```bash
sudo bash /mnt/c/tinet/check_mac.sh
```

This will check:
- DNS configuration
- Docker installation and service status
- tinet installation
- Root privileges

All checks should pass successfully.

## Usage

### Basic Workflow

1. **Enter the VM**:
   ```bash
   multipass shell UBUNTU
   ```

2. **Switch to root**:
   ```bash
   sudo su -
   ```

3. **Navigate to mounted directory**:
   ```bash
   cd /mnt/c/tinet
   ```

4. **Deploy a network topology**:
   ```bash
   tinet up -c spec_01.yaml | sh -x
   ```

5. **Run tests** (if defined in the spec):
   ```bash
   tinet test -c spec_01.yaml | sh -x
   ```

6. **Clean up**:
   ```bash
   tinet down -c spec_01.yaml | sh -x
   ```

### Available Network Specifications

- **spec_01.yaml** - Complex enterprise network with:
  - Multiple routers (rt1, rt2, rt3) with OSPF routing
  - Firewall (fw1) with NAT and filtering rules
  - Load balancer (lb1) with HAProxy
  - DNS infrastructure (root, TLD, authoritative servers)
  - Web servers (sv1, sv2) with nginx
  - Switches (sw1, sw2) with VLAN support
  - DHCP clients (cl1, cl2, cl3)

- **spec_02.yaml** - Additional topology configuration
- **spec_03.yaml** - Additional topology configuration
- **spec_04.yaml** - Additional topology configuration
- **spec_05.yaml** - Additional topology configuration

## Network Components

The spec_01.yaml topology includes:

### Routers
- **rt1**: Edge router with DHCP, DNS forwarding, NAT
- **rt2**: Core router with OSPF, static routes
- **rt3**: Distribution router with OSPF

### Switches
- **sw1**: Access switch for client network
- **sw2**: Distribution switch with VLAN (802.1Q)

### Services
- **fw1**: Firewall with iptables, DNAT/SNAT
- **lb1**: Load balancer (HAProxy) + DNS server (BIND9)
- **ns1**: Recursive DNS resolver (Unbound)
- **sv1, sv2**: Web servers (nginx) with SSL/TLS

### Clients
- **cl1, cl2**: DHCP clients
- **cl3**: Static IP client

## Troubleshooting

### VM Issues

**VM won't start:**
```bash
multipass list
multipass delete UBUNTU
multipass purge
# Then recreate from Step 3
```

**Mount not working:**
```bash
multipass umount UBUNTU
multipass mount $(pwd):/mnt/c/tinet UBUNTU
```

### Setup Script Errors

**Docker installation fails:**
- Check internet connectivity
- Review logs: `/var/log/setup.log`
- Ensure Ubuntu version is 22.04 or newer

**Permission denied:**
- Ensure you're running as root: `sudo su -`

### tinet Issues

**Container fails to start:**
```bash
# Check Docker status
systemctl status docker

# View container logs
docker logs <container_name>

# Clean up all containers
tinet down -c spec_XX.yaml | sh -x
docker system prune -af
```

**Network connectivity issues:**
- Verify all containers are running: `docker ps`
- Check routes: `docker exec <container> ip route`
- Test connectivity: `docker exec <container> ping <target>`

## Tips

### Quick Access to VM

Create an alias in your `~/.zshrc` or `~/.bashrc`:

```bash
alias tinet-vm='multipass shell UBUNTU'
```

### Persist Containers

Containers continue running in Docker daemon even after exiting the VM. You can re-attach when you reconnect.

### View Container Logs

```bash
docker logs <container_name>
docker exec -it <container_name> bash
```

## Learning Resources

- **tinet Documentation**: https://github.com/tinynetwork/tinet
- **Docker Networking**: https://docs.docker.com/network/
- **FRR Routing**: https://frrouting.org/
- **HAProxy**: https://www.haproxy.org/
- **BIND9**: https://www.isc.org/bind/

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request
