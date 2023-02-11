#!/bin/bash
clear
echo -e "\033[0;33m"
echo "================================================================="
echo " ░██████╗██████╗░████████╗░░░░░░███╗░░██╗░█████╗░██████╗░███████╗"
echo " ██╔════╝██╔══██╗╚══██╔══╝░░░░░░████╗░██║██╔══██╗██╔══██╗██╔════╝"
echo " ╚█████╗░██████╔╝░░░██║░░░█████╗██╔██╗██║██║░░██║██║░░██║█████╗░░"
echo " ░╚═══██╗██╔═══╝░░░░██║░░░╚════╝██║╚████║██║░░██║██║░░██║██╔══╝░░"
echo " ██████╔╝██║░░░░░░░░██║░░░░░░░░░██║░╚███║╚█████╔╝██████╔╝███████╗"
echo " ╚═════╝░╚═╝░░░░░░░░╚═╝░░░░░░░░░╚═╝░░╚══╝░╚════╝░╚═════╝░╚══════╝"
echo "================================================================="
echo -e "\e[0m"
echo -e '\e[33mNama Project =\e[55m' Coreum 
echo -e '\e[33mKomunitas Kami =\e[55m' Sipaling Testnet X CNESIA112
echo -e '\e[33mChannel Telegram =\e[55m' https://t.me/ssipalingtestnet
echo -e '\e[33mGroup Telegram =\e[55m' https://t.me/diskusisipalingairdrop
echo -e "\e[0m"
echo "================================================================="

sleep 2


# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
COREUM_PORT=52
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
export CORE_CHAIN_ID="coreum-testnet-1"
export CORE_DENOM="utestcore"
export CORE_NODE="https://full-node-pluto.testnet-1.coreum.dev"
export CORE_FAUCET_URL="https://api.testnet-1.coreum.dev"
export CORE_COSMOVISOR_VERSION="v1.3.0"
export CORE_VERSION="v0.1.1"
export CORE_CHAIN_ID_ARGS="--chain-id=$CORE_CHAIN_ID"
export CORE_NODE_ARGS="--node=$CORE_NODE $CORE_CHAIN_ID_ARGS"
export CORE_HOME=$HOME/.core/"$CORE_CHAIN_ID"
export CORE_BINARY_NAME=$(arch | sed s/aarch64/cored-linux-arm64/ | sed s/x86_64/cored-linux-amd64/)
export COSMOVISOR_TAR_NAME=cosmovisor-$CORE_COSMOVISOR_VERSION-linux-$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/).tar.gz


echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$COREUM_CHAIN_ID\e[0m"
echo -e "Your Coreum port: \e[1m\e[32m$COREUM_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1

# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade


# install go
ver="1.18.2" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1

# download binary
mkdir -p $CORE_HOME/bin
cd $HOME
curl -LOf https://github.com/CoreumFoundation/coreum/releases/download/$CORE_VERSION/$CORE_BINARY_NAME
mv $CORE_BINARY_NAME $CORE_HOME/bin/cored
chmod +x $CORE_HOME/bin/*
cored version

# config
CORE_NODE_CONFIG=$CORE_HOME/config/config.toml

# Update node config with CORE_EXTERNAL_IP
crudini --set $CORE_NODE_CONFIG p2p addr_book_strict false
crudini --set $CORE_NODE_CONFIG p2p external_address "\"tcp://$CORE_EXTERNAL_IP:26656\""
crudini --set $CORE_NODE_CONFIG rpc laddr "\"tcp://0.0.0.0:26657\""


# init
cored init $MONIKER $CORE_CHAIN_ID_ARGS

# Set the config path variables.
CORE_APP_CONFIG=$CORE_HOME/config/app.toml


# create service
sudo tee /etc/systemd/system/cored.service > /dev/null << EOF
[Unit]
Description=Coreum Node
After=network-online.target
[Service]
User=$USER
ExecStart=/root/.core/coreum-testnet-1/bin/cored start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable cored
sudo systemctl restart cored && sudo journalctl -u cored -f -o cat

echo '=============== DONO ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u cored -f -o cat\e[0m'


