# ODIN MAINNET FREYA

## Hardware Requirements
* **Minimal**
    * 4 GB RAM
    * 100 GB SSD
    * 3.2 x4 GHz CPU
* **Recommended**
    * 8 GB RAM
    * 1 TB NVME SSD
    * 3.2 GHz x4 GHz CPU

## Operating System

* **Recommended**
    * Linux(x86_64)


## Installation Steps
#### 1. Basic Packages
```bash:
# update the local package list and install any available upgrades 
sudo apt-get update && sudo apt upgrade -y 
# install toolchain and ensure accurate time synchronization 
sudo apt-get install make build-essential gcc git jq chrony wget curl -y
```

#### 2. Install Go
Follow the instructions [here](https://golang.org/doc/install) to install Go.

Alternatively, for Ubuntu LTS, you can do:
```bash:
wget https://golang.org/dl/go1.18.10.linux-amd64.tar.gz
sudo tar -C /usr/local -xzvf go1.18.10.linux-amd64.tar.gz
```

Unless you want to configure in a non standard way, then set these in the `.profile` in the user's home (i.e. `~/`) folder.

```bash:
cat <<EOF >> ~/.profile
export MONIKER_NAME="CHANGE_ME"
EXPORT LIVE_RPC_NODE="http://35.241.221.154:26657"
export CHAIN_ID="odin-mainnet-freya"
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile
go version
```

Output should be: `go version go1.18.10 linux/amd64`

<a id="install-odind"></a>
### Install Odind from source

#### 1. Clone repository

* Clone git repository
```shell
git clone https://github.com/ODIN-PROTOCOL/odin-core.git
```
* Checkout latest tag
```shell
cd odin-core
git fetch --tags
git checkout v0.6.2
```
#### 2. Install CLI
```shell
make all
```
	
To confirm that the installation was successful, you can run:

```bash:
odind version
```
Output should be: `v0.6.2`

## Instruction for new validators

### Init
This step is essential to init a `secp256k1` (required) key instead of `ed25519` (default)
```bash:
odind init "change_me" --chain-id $CHAIN_ID
```

### Generate keys

```bash:
# To create new keypair - make sure you save the mnemonics!
odind keys add operator
```

or
```
# Restore existing odin wallet with mnemonic seed phrase. 
# You will be prompted to enter mnemonic seed. 
odind keys add operator --recover
```
or
```
# Add keys using ledger
odind keys show operator --ledger
```

Check your key:
```
# Query the keystore for your public address 
odind keys show operator -a
```

## Validator Setup Instructions

### Set minimum gas fees
```bash:
perl -i -pe 's/^minimum-gas-prices = .+?$/minimum-gas-prices = "0.0125loki"/' ~/.odin/config/app.toml
```

### Add persistent peers
Provided is a small list of peers, however more can be found the `peers.txt` file
```bash:
SEEDS="$(curl https://chainregistry.xyz/v1/mainnet/odin/peers/seed_string)"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" ~/.odin/config/config.toml
```

### Download new genesis file
```bash:
curl https://raw.githubusercontent.com/ODIN-PROTOCOL/networks/master/mainnets/odin-mainnet-freya/genesis.json > ~/.odin/config/genesis.json
```

### Download and extract the latest snapshot
Navigate to https://imperator.co/services/odin and find the latest snapshot. update the LATEST variable below with the latest snapshot url. 
Example:
```bash:
LATEST="https://api-minio-nord.imperator.co/snapshots/odin/odin_8765146.tar.lz4"
curl -o - -L $LATEST | lz4 -c -d - | tar -xv -C $HOME/.odin
```

### Setup Unit/Daemon file

```bash:
# 1. create daemon file
sudo touch /etc/systemd/system/odin.service

# 2. run:
sudo tee -a /etc/systemd/system/odin.service<<EOF
[Unit]
Description=Odin daemon
After=network-online.target

[Service]
User="$(whoami)"
ExecStart=/home/"$(whoami)"/go/bin/odind start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# 3. reload the daemon
systemctl daemon-reload

# 4. enable service - this means the service will start up 
# automatically after a system reboot
sudo systemctl enable odin.service

# 5. start daemon
sudo systemctl start odin.service
```

In order to watch the service run, you can do the following:
```
journalctl -u odin.service -f
```

Congratulations! You now have a full node. Once the node is synced with the network, 
you can then make your node a validator.

### Create validator
1. Transfer funds to your validator address. A minimum of 1 ODIN (1000000loki) is required to start a validator.

2. Confirm your address has the funds.

```
odind q bank balances $(odind keys show -a operator) --node --node $LIVE_RPC_NODE
```

3. Run the create-validator transaction
**Note: 1,000,000 loki = 1 ODIN, so this validator will start with 1 ODIN**

```bash:
odind tx staking create-validator \ 
--amount 1000000loki \ 
--commission-max-change-rate "0.05" \ 
--commission-max-rate "0.10" \ 
--commission-rate "0.05" \ 
--min-self-delegation "1" \ 
--chain-id odin-mainnet-freya \
--details "validators write bios too" \ 
--pubkey $(odind tendermint show-validator) \ 
--moniker $MONIKER_NAME \ 
--chain-id $CHAIN_ID \ 
--gas-prices 0.0125loki --gas-adjustment 1.2 \
--node $LIVE_RPC_NODE \
--from operator
```

To ensure your validator is active, run:
```
odind q staking validators --node $LIVE_RPC_NODE | grep moniker
```

### Backup critical files
mount your thumbdrive to /mnt/thumbdrive , then
```bash:
cp ~/.odin/config/priv_validator_key.json /mnt/thumbdrive/
cp ~/.odin/config/node_key.json /mnt/thumbdrive
```
