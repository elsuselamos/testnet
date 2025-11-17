
# Download the latest binary for AMD64 architecture
 
    wget https://file.blocksync.me/stable/stabled
    chmod +x stabled && mv stabled ~/go/bin
    stabled version
    echo "export MONIKER="Mynode"" >> $HOME/.bash_profile
    echo "export STABLE_PORT="30"" >> $HOME/.bash_profile
    source $HOME/.bash_profile
    stabled init $MONIKER --chain-id stabletestnet_2201-1

# Download genesis.json, addrbook.json
   
    curl -Ls https://file.blocksync.me/stable/genesis.json > $HOME/.stabled/config/genesis.json 
    curl -Ls https://file.blocksync.me/stable/addrbook.json > $HOME/.stabled/config/addrbook.json

# set custom ports in app.toml file

    sed -i.bak -e "s%:1317%:${STABLE_PORT}317%g;
    s%:8080%:${STABLE_PORT}080%g;
    s%:9090%:${STABLE_PORT}090%g;
    s%:9091%:${STABLE_PORT}091%g;
    s%:8545%:${STABLE_PORT}545%g;
    s%:8546%:${STABLE_PORT}546%g;
    s%:6065%:${STABLE_PORT}065%g" $HOME/.stabled/config/app.toml

# set custom ports in config.toml file

    sed -i.bak -e "s%:26658%:${STABLE_PORT}658%g;
    s%:26657%:${STABLE_PORT}657%g;
    s%:6060%:${STABLE_PORT}060%g;
    s%:26656%:${STABLE_PORT}656%g;
    s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${STABLE_PORT}656\"%;
    s%:26660%:${STABLE_PORT}660%g" $HOME/.stabled/config/config.toml

# config pruning

    sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.stabled/config/app.toml 
    sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.stabled/config/app.toml
    sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"20\"/" $HOME/.stabled/config/app.toml

# set minimum gas price, enable prometheus and disable indexing

    sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.stabled/config/config.toml
    sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.stabled/config/config.toml
# set peers

    SEEDS="5ed0f977a26ccf290e184e364fb04e268ef16430@37.187.147.27:26656,128accd3e8ee379bfdf54560c21345451c7048c7@37.187.147.22:26656"
    PEERS="5ed0f977a26ccf290e184e364fb04e268ef16430@37.187.147.27:26656,128accd3e8ee379bfdf54560c21345451c7048c7@37.187.147.22:26656,9d1150d557fbf491ec5933140a06cdff40451dee@164.68.97.210:26656,e33988e27710ee1a7072f757b61c3b28c922eb59@185.232.68.94:11656,ff4ff638cee05df63d4a1a2d3721a31a70d0debc@141.94.138.48:26664"
    sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
           -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.stabled/config/config.toml
	   
# Edit app.toml Enable JSON-RPC for EVM compatibility

    [json-rpc]
    enable = true
    address = "0.0.0.0:8546"
    ws-address = "0.0.0.0:8547"
    allow-unprotected-txs = true

**#Setup cosmovisor - make sure that cosmovisor installed on server**
# Setup Cosmovisor - Make sure that cosmovisor installed on server

    mkdir -p ~/.stabled/cosmovisor/genesis/bin
    mkdir -p ~/.stabled/cosmovisor/upgrades
    cp ~/go/bin/stabled ~/.stabled/cosmovisor/genesis/bin/
    ln -s ~/.stabled/cosmovisor/genesis ~/.stabled/cosmovisor/current
    ls -la ~/.stabled/cosmovisor/

# Setup Service

    sudo tee /etc/systemd/system/stabled.service > /dev/null <<EOF
    [Unit]
    Description=Cosmovisor Stable daemon
    After=network-online.target
    
    [Service]
    Environment="DAEMON_NAME=stabled"
    Environment="DAEMON_HOME=$HOME/.stabled"
    Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
    Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
    Environment="DAEMON_LOG_BUFFER_SIZE=512"
    Environment="UNSAFE_SKIP_BACKUP=true"
    User=$USER
    ExecStart=$(which cosmovisor) run start --chain-id stabletestnet_2201-1
    Restart=always
    RestartSec=3
    LimitNOFILE=65535
    StandardOutput=journal
    StandardError=journal
    SyslogIdentifier=stable
    
    [Install]
    WantedBy=multi-user.target
    EOF
# Downlaod snapshot

    SNAP_NAME=$(curl -s https://file.blocksync.me/stable/ | grep -o 'snapshot_[0-9]\+\.tar\.lz4' | sort | tail -n 1)
    curl -o - -L https://file.blocksync.me/stable/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.stabled
# Enable service and start node

    sudo systemctl enable stabled && systemctl start stabled && journalctl -fu stabled -o cat
