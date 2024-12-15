
![enter image description here](https://github.com/elsuselamos/testnet/blob/main/sonaric/sonaric.jpg)

Website:  https://sonaric.xyz/

Twitter: https://x.com/Sonaricnetwork

Incentivized Infor: https://docs.sonaric.xyz/community/incentive-program.html

**#Server preparation**

    sudo apt update && sudo apt upgrade -y
    sudo apt install git wget curl make clang pkg-config libssl-dev build-essential lz4 snapd protobuf-compiler jq gcc curl -y

**#Installation**

     wget https://raw.githubusercontent.com/monk-io/sonaric-install/main/linux-install-sonaric.sh
     bash linux-install-sonaric.sh

**#Check Node information**

    sonaric node-info

**#Check Node Points**

    sonaric points

**#Backup Wallet**

    sonaric identity-export -o mywallet.identity
**<<IMPORTANT!!>>**
Enter password and a "wallet.identity" file will be created at root folder. Download and save this file to safety place 

**#Recover Wallet**

    sonaric identity-import -i mywallet.identity

**#Re-name your node**

    sonaric node-rename

**#Node upgrading**

    sudo apt upgrade sonaric

