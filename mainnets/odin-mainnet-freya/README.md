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

Recommended version of go is 1.20.13

Alternatively, for Ubuntu LTS, you can do:
```bash:
wget https://golang.org/dl/go1.20.13.linux-amd64.tar.gz
sudo tar -C /usr/local -xzvf go1.20.13.linux-amd64.tar.gz
```

Unless you want to configure in a non standard way, then set these in the `.profile` in the user's home (i.e. `~/`) folder.

```bash:
cat <<EOF >> ~/.profile
export MONIKER_NAME="CHANGE_ME"
EXPORT LIVE_RPC_NODE="http://34.38.73.153:26657"
export CHAIN_ID="odin-mainnet-freya"
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile
go version
```

Output should be: `go version go1.20.13 linux/amd64`

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
git checkout v0.7.9
```

#### 2. Install CLI
```shell
make all
```
	
To confirm that the installation was successful, you can run:

```bash:
odind version
```
Output should be: `0.7.9`

## Instruction for new validators

### Init
This step is essential to init a `secp256k1` (required) key instead of `ed25519` (default), if you don't want to use horcrux for distributed signing.

If you want to use `ed25519` key type for remote signing, use this workaround method:

```bash:
odind start
```

node will crush, but will generate your ~/.odind/config/priv_validator_key.json in `ed25519` format. Copy the file and remove `~/.odind/config` folder.

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
PEERS="d23013e1a0a82d71d251f96c63609ee88af2e29c@34.38.73.153:26656,3ae5858dbad9c65f07f1bd8ccf6c2bf9e089dbb1@34.78.8.181:26656,5cfe57184c002bf2050b5a1d1d247dccf18784f1@34.78.212.147:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.odin/config/config.toml
```

### Download new genesis file
```bash:
curl https://storage.googleapis.com/odin-mainnet-freya/genesis.json > ~/.odin/config/genesis.json
```

check sha256sum for downloaded genesis:

```bash:
sha256sum ~/.odin/config/genesis.json
253d946d4986673f6ea5ad410380ad8ac879b04b7a35a05f69c6fc459b2c1afc  ~/.odin/config/genesis.json
```

checksum should match

### If you are upgrading from old version
It is important to clean ~/.odin/data folder before joining upgraded `odin-mainnet-freya` chain, if you're spinning your validator for the first time 

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
