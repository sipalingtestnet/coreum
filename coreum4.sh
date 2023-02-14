#
# // Copyright (C) 2022 Salman Wahib Recoded By NodeX Capital
#

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


sleep 1
PORT=52


echo "export PORT=${PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $NODENAME ]; then
	 [ENTER YOUR NODE] > " NODENAME"
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[35m$NODENAME\e[0m"
echo -e "NODE CHAIN CHAIN  : \e[1m\e[35mcoreum-testnet-1\e[0m"
echo -e "NODE PORT      : \e[1m\e[35m$PORT\e[0m"
echo ""

# Package
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade

# Install GO
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.5.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)

# Get mainnet version of MARS

cd $HOME
curl -LOf https://github.com/CoreumFoundation/coreum/releases/download/v0.1.1/cored-linux-amd64
chmod +x cored-linux-amd64
mv cored-linux-amd64 cored
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0


# Prepare binaries for Cosmovisor
mkdir -p $HOME/.core/coreum-testnet-1/cosmovisor/genesis/bin
cp cored $HOME/.core/coreum-testnet-1/cosmovisor/genesis/bin/

# Create application symlinks
ln -s $HOME/.core/coreum-testnet-1/cosmovisor/genesis $HOME/.core/coreum-testnet-1/cosmovisor/current
sudo ln -s $HOME/.core/coreum-testnet-1/cosmovisor/current/bin/cored /usr/bin/cored

# Init generation
cored config chain-id coreum-testnet-1
cored config keyring-backend test
cored config node tcp://localhost:${PORT}657
cored init $NODENAME --chain-id coreum-testnet-1

# Set peers and seeds
PEERS="69d7028b7b3c40f64ea43208ecdd43e88c797fd6@34.69.126.231:26656,b2978432c0126f28a6be7d62892f8ded1e48d227@34.70.241.13:26656,7c0d4ce5ad561c3453e2e837d85c9745b76f7972@35.238.77.191:26656,0aa5fa2507ada8a555d156920c0b09f0d633b0f9@34.173.227.148:26656,4b8d541efbb343effa1b5079de0b17d2566ac0fd@34.172.70.24:26656,27450dc5adcebc84ccd831b42fcd73cb69970881@35.239.146.40:26656,5add70ec357311d07d10a730b4ec25107399e83c@5.196.7.58:26656,1a3a573c53a4b90ab04eb47d160f4d3d6aa58000@35.233.117.165:26656,abbeb588ad88176a8d7592cd8706ebbf7ef20cfe@185.241.151.197:26656,39a34cd4f1e908a88a726b2444c6a407f67e4229@158.160.59.199:26656,051a07f1018cfdd6c24bebb3094179a6ceda2482@138.201.123.234:26656,cc6d4220633104885b89e2e0545e04b8162d69b5@75.119.134.20:26656"
SEEDS="64391878009b8804d90fda13805e45041f492155@35.232.157.206:26656,53f2367d8f8291af8e3b6ca60efded0675ff6314@34.29.15.170:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.core/coreum-testnet-1/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.core/coreum-testnet-1/config/config.toml

# Download genesis and addrbook
curl -Ls https://snap.nodexcapital.com/coreum/genesis.json > $HOME/.core/coreum-testnet-1/config/genesis.json
curl -Ls https://snap.nodexcapital.com/coreum/addrbook.json > $HOME/.core/coreum-testnet-1/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.core/coreum-testnet-1/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%" $HOME/.core/coreum-testnet-1/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.core/coreum-testnet-1/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.core/coreum-testnet-1/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.core/coreum-testnet-1/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.core/coreum-testnet-1/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$DENOM\"/" $HOME/.core/coreum-testnet-1/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/.core/coreum-testnet-1/config/app.toml
cored tendermint unsafe-reset-all --home $HOME/.core/coreum-testnet-1 --keep-addr-book
curl -L https://snap.nodexcapital.com/coreum/coreum-latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.core/coreum-testnet-1/

#Delete Trash File
cd $HOME/.core/coreum-testnet-1/
rm -rf data
cd $HOME/.core/coreum-testnet-1/coreum-testnet-1
mv data $HOME/.core/coreum-testnet-1
cd $HOME/.core/coreum-testnet-1/
rm -rf $HOME/.core/coreum-testnet-1/coreum-testnet-1

# Create Service
sudo tee /etc/systemd/system/cored.service > /dev/null << EOF
[Unit]
Description=cored
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.core/coreum-testnet-1"
Environment="DAEMON_NAME=cored"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF


# Register And Start Service
sudo systemctl start cored
sudo systemctl daemon-reload
sudo systemctl enable cored

echo -e "\e[1m\e[35mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[35msystemctl status cored\e[0m"
echo -e "CHECK RUNNING LOGS : \e[1m\e[35mjournalctl -fu cored -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[35mcurl -s localhost:${PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
