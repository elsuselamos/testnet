# Allora Network RPC Node Setup Guide

This guide provides step-by-step instructions for setting up an Allora Network RPC node optimized for handling multiple workers. The setup includes Docker containerization and custom configurations for high-performance operation.

## Prerequisites

- Ubuntu 20.04 LTS or higher
- Minimum 4 CPU cores
- 8GB RAM (16GB recommended)
- 200GB SSD storage
- Root or sudo access
- Stable internet connection

## Quick Start

### 1. System Update and Dependencies

First, ensure your system is up to date and install the required dependencies:

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential dependencies
sudo apt install ca-certificates zlib1g-dev libncurses5-dev \
    libgdbm-dev libnss3-dev curl git wget make jq build-essential \
    pkg-config lsb-release libssl-dev libreadline-dev libffi-dev \
    gcc screen unzip lz4 -y

# Install Python and pip
sudo apt install python3
sudo apt install python3-pip

# Verify installations
python3 --version
pip3 --version
```

### 2. Docker Setup

Install and configure Docker:

```bash
# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Install Docker Compose
VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/"$VER"/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo groupadd docker
sudo usermod -aG docker $USER

# Verify installations
docker version
docker-compose --version
```

### 3. Go Installation

Install Go programming language:

```bash
# Remove any existing Go installation
sudo rm -rf /usr/local/go

# Download and install Go 1.22.4
curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local

# Set up environment variables
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile
source .bash_profile

# Verify installation
go version
```

### 4. Allora Node Setup

Clone and build the Allora chain:

```bash
# Clone repository
git clone https://github.com/allora-network/allora-chain.git
cd allora-chain

# Build
make all

# Install text editor
apt install nano
```

### 5. Node Configuration

Edit`docker-compose.yaml`:

```yaml
services:
  allora-node:
    container_name: allora-node
    image: "alloranetwork/allora-chain:v0.6.0" # docker image without cosmovisor. use vx.x.x-upgrader for upgrade image
    environment:
      - NETWORK=allora-testnet-1
      - MONIKER=RPCFULLNODE
      - APP_HOME=/data
      - HOME=/data
      - STATE_SYNC_RPC1=https://allora-rpc.testnet.allora.network:443
      - STATE_SYNC_RPC2=https://allora-rpc.testnet.allora.network:443
      #- UPGRADE=true # set this to true for chain upgrade runs
    volumes:
      - ./data:/data
      - ./scripts/:/scripts
    ports:
      - "26656-26657:26656-26657"
    user: "0:0"
    entrypoint: /scripts/l1_node.sh

```

### 6. Launch and Synchronization

```bash
# Start the node
docker compose up -d

# Monitor synchronization status
curl -s http://localhost:26657/status | jq .
```

> Wait until `catching_up` becomes `false` before proceeding with additional configuration.

### 7. Advanced Configuration

After synchronization, optimize the node for high performance:

1. Navigate to config directory:
```bash
cd /data/config
```

2. Edit `config.toml` with optimized settings for ~5000 workers:

```toml
# Highlights of important settings
[mempool]
size = 1000000
cache_size = 1000000
max_txs_bytes = 83600028608

[rpc]
max_open_connections = 20000
max_subscription_clients = 6000

[consensus]
timeout_propose = "5s"
timeout_commit = "10s"

[statesync]
enable = true
rpc_servers = "https://allora-rpc.testnet.allora.network:443,https://allora-rpc.testnet.allora.network:443"
```

3. Restart the node:
```bash
docker compose down
docker compose up -d
```

## Performance Optimization

The configuration provided is optimized for:
- High transaction throughput
- Multiple concurrent connections
- Fast state synchronization
- Efficient memory usage
- Stable worker connections

## Monitoring

Monitor your node's status using:
```bash
# Check sync status
curl -s http://localhost:26657/status | jq .

# Monitor logs
docker logs -f allora-node
```

## Important Notes

1. Ensure sufficient disk space for chain growth
2. Monitor system resources regularly
3. Keep your system updated
4. Backup your configuration files
5. Monitor node performance and adjust settings as needed

## Contributing

Feel free to open issues and pull requests if you have suggestions for improvements or find any bugs.


## Acknowledgments

- Allora Network team
- Community contributors

---
Don't forget to star this repository if you find it helpful!
