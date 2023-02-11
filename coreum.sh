#!/bin/bash
clear
echo -e "\033[0;33m"
echo "================================================================="
echo " ░██████╗██████╗░████████╗░░░░░░███╗░░██╗░█████╗░██████╗░███████╗
echo " ██╔════╝██╔══██╗╚══██╔══╝░░░░░░████╗░██║██╔══██╗██╔══██╗██╔════╝
echo " ╚█████╗░██████╔╝░░░██║░░░█████╗██╔██╗██║██║░░██║██║░░██║█████╗░░
echo " ░╚═══██╗██╔═══╝░░░░██║░░░╚════╝██║╚████║██║░░██║██║░░██║██╔══╝░░
echo " ██████╔╝██║░░░░░░░░██║░░░░░░░░░██║░╚███║╚█████╔╝██████╔╝███████╗
echo " ╚═════╝░╚═╝░░░░░░░░╚═╝░░░░░░░░░╚═╝░░╚══╝░╚════╝░╚═════╝░╚══════╝
echo "================================================================="
echo "================================================================="
echo -e "\e[0m"
echo -e '\e[33mNama Project =\e[55m' Coreum 
echo -e '\e[33mKomunitas Kami =\e[55m' Sipaling Testnet-CNESIA112
echo -e '\e[33mChannel Telegram =\e[55m' https://t.me/ssipalingtestnet
echo -e '\e[33mGroup Telegram =\e[55m' https://t.me/diskusisipalingairdrop
echo -e "\e[0m"
echo "================================================================="

sleep 2
CHAIN=coreum-testnet-1
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

# download genesis and addrbook
wget -qO $HOME/.core/config/genesis.json "https://snap.nodexcapital.com/coreum/genesis.json"
wget -O $HOME/.core/config/addrbook.json "https://snap.nodexcapital.com/coreum/addrbook.json"

# set peers, gas prices and seeds
# Set peers and seeds
PEERS="69d7028b7b3c40f64ea43208ecdd43e88c797fd6@34.69.126.231:26656,b2978432c0126f28a6be7d62892f8ded1e48d227@34.70.241.13:26656,7c0d4ce5ad561c3453e2e837d85c9745b76f7972@35.238.77.191:26656,0aa5fa2507ada8a555d156920c0b09f0d633b0f9@34.173.227.148:26656,4b8d541efbb343effa1b5079de0b17d2566ac0fd@34.172.70.24:26656,27450dc5adcebc84ccd831b42fcd73cb69970881@35.239.146.40:26656,5add70ec357311d07d10a730b4ec25107399e83c@5.196.7.58:26656,1a3a573c53a4b90ab04eb47d160f4d3d6aa58000@35.233.117.165:26656,abbeb588ad88176a8d7592cd8706ebbf7ef20cfe@185.241.151.197:26656,39a34cd4f1e908a88a726b2444c6a407f67e4229@158.160.59.199:26656,051a07f1018cfdd6c24bebb3094179a6ceda2482@138.201.123.234:26656,cc6d4220633104885b89e2e0545e04b8162d69b5@75.119.134.20:26656"
SEEDS="64391878009b8804d90fda13805e45041f492155@35.232.157.206:26656,53f2367d8f8291af8e3b6ca60efded0675ff6314@34.29.15.170:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$FOLDER/$CHAIN/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$FOLDER/$CHAIN/config/config.toml
# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/$FOLDER/$CHAIN/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%" $HOME/$FOLDER/$CHAIN/config/app.toml

# config pruning

pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$FOLDER/$CHAIN/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$FOLDER/$CHAIN/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$FOLDER/$CHAIN/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$FOLDER/$CHAIN/config/app.toml

#set null indexer
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.core/config/config.toml


echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1


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
