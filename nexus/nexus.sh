#!/bin/bash
SERVICE_NAME="nexus"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

show "Installation Rust..." "progress"
if ! source <(wget -O - https://raw.githubusercontent.com/choir94/Airdropguide/refs/heads/main/rust.sh); then
    show "Cannot install Rust." "error"
    exit 1
fi

show "Updating Independencies..." "progress"
if ! sudo apt update; then
    show "Cannot update packages." "error"
    exit 1
fi

if ! command -v git &> /dev/null; then
    show "Git not installed. Installing git..." "progress"
    if ! sudo apt install git -y; then
        show "Cannot install git." "error"
        exit 1
    fi
else
    show "Git installed Successfull."
fi

if [ -d "$HOME/network-api" ]; then
    show "Deletting Package stored..." "progress"
    rm -rf "$HOME/network-api"
fi

sleep 3

show "Nexus-XYZ network API..." "progress"
if ! git clone https://github.com/nexus-xyz/network-api.git "$HOME/network-api"; then
    show "Gagal nggandha repositori." "error"
    exit 1
fi

cd $HOME/network-api/clients/cli

show "Mandatory Independencies Installing..." "progress"
if ! sudo apt install pkg-config libssl-dev -y; then
    show "Cannot install." "error"
    exit 1
fi

if systemctl is-active --quiet nexus.service; then
    show "nexus.service saiki mlaku. Mandhegake lan mateni..."
    sudo systemctl stop nexus.service
    sudo systemctl disable nexus.service
else
    show "nexus.service ora mlaku."
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

show "Reload systemd and running..." "progress"
if ! sudo systemctl daemon-reload; then
    show "Cannot reload systemd." "error"
    exit 1
fi

if ! sudo systemctl start $SERVICE_NAME.service; then
    show "Cannot running." "error"
    exit 1
fi

if ! sudo systemctl enable $SERVICE_NAME.service; then
    show "Cannot Enable service." "error"
    exit 1
fi

show "Status service:" "progress"
if ! sudo systemctl status $SERVICE_NAME.service; then
    show "Gagal njupuk status layanan." "error"
fi

show "Installation and Setting up completed!"
echo "systemctl status nexus.service"
echo "journalctl -u nexus.service -f -n 50"
