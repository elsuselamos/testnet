#!/bin/bash
SERVICE_NAME="nexus"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

source <(wget -O - https://raw.githubusercontent.com/choir94/Airdropguide/refs/heads/main/rust.sh)
sudo apt update
sudo apt install git -y
if [ -d "$HOME/network-api" ]; then
    show "Deletting Package stored..." "progress"
    rm -rf "$HOME/network-api"
else
    show "Network API Removed. Go to next step"
fi
sleep 3
show "Nexus-XYZ network API..." "progress"
if ! git clone https://github.com/nexus-xyz/network-api.git "$HOME/network-api"; then
    show "Gagal nggandha repositori." "error"
    exit 1
fi
cd $HOME/network-api/clients/cli
sudo apt install pkg-config libssl-dev -y
if systemctl is-active --quiet nexus.service; then
    sudo systemctl stop nexus.service
    sudo systemctl disable nexus.service
else
    show "nexus.service not created. Now begin to create a service"
fi

show "Creating systemd..." "progress"
if ! sudo bash -c "cat > $SERVICE_FILE <<EOF
[Unit]
Description=Nexus XYZ Prover Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/network-api/clients/cli
Environment=NONINTERACTIVE=1
ExecStart=$HOME/.cargo/bin/cargo run --release --bin prover -- beta.orchestrator.nexus.xyz
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"; then
    show "Cannot create systemd." "error"
    exit 1
fi

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl start $SERVICE_NAME.service && journalctl -fu nexus.service
