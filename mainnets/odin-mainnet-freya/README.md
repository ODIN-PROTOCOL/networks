# ODIN MAINNET FREYA

## First part is to submit the gentx. >> NOW CLOSED <<

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
sudo apt-get install make build-essential gcc git jq chrony -y
```

#### 2. Install Go
Follow the instructions [here](https://golang.org/doc/install) to install Go.

Alternatively, for Ubuntu LTS, you can do:
```bash:
wget https://golang.org/dl/go1.17.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.3.linux-amd64.tar.gz
```

Unless you want to configure in a non standard way, then set these in the `.profile` in the user's home (i.e. `~/`) folder.

```bash:
cat <<EOF >> ~/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile
go version
```

Output should be: `go version go1.17.3 linux/amd64`


### Install Odind from source

#### 1. Clone repository

>Prerequisite: git. [ref](https://github.com/git/git)
>Optional requirement: GNU make. [ref](https://www.gnu.org/software/make/manual/html_node/index.html)
* Clone git repository
```shell
git clone https://github.com/GeoDB-Limited/odin-core.git
```
* Checkout latest tag
```shell
cd odin-core
git fetch --tags
git checkout v0.1.0
```
#### 2. Install CLI
```shell
make all
```
	
To confirm that the installation was successful, you can run:

```bash:
odind version
```
Output should be: `v0.1.0`

### Generate keys

```bash:
# To create new keypair - make sure you save the mnemonics!
odind keys add <key-name> 
```

or
```
# Restore existing odin wallet with mnemonic seed phrase. 
# You will be prompted to enter mnemonic seed. 
odind keys add <key-name> --recover
```
or
```
# Add keys using ledger
odind keys show <key-name> --ledger
```

Check your key:
```
# Query the keystore for your public address 
odind keys show <key-name> -a
```

## Validator run instruction

### Set minimum gas fees
perl -i -pe 's/^minimum-gas-prices = .+?$/minimum-gas-prices = "0.0125loki"/' ~/.odin/config/app.toml

### Add persistent peers
Provided is a small list of peers, however more can be found the `peers.txt` file
```bash:
PEERS="3c9f836af6e8b00e77ca5792d5a92e2fea8d3f20@116.202.169.136:26656,46fd2ff68ac8128ce04aed6584fa67b048c228ee@162.55.214.187:26766,9d16b1ce74a34b869d69ad5fe34eaca614a36ecd@35.241.238.207:26656,02e905f49e1b869f55ad010979931b542302a9e6@35.241.221.154:26656,4847c79f1601d24d3605278a0183d416a99aa093@34.140.252.7:26656,0165cd0d60549a37abb00b6acc8227a54609c648@34.79.179.216:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.odin/config/config.toml
```

### Download genesis file
```bash:
curl https://raw.githubusercontent.com/ODIN-PROTOCOL/networks/master/mainnets/odin-mainnet-freya/final_genesis.json > ~/.odin/config/genesis.json
```

Verify the hash `283af746fe979c937965f33faa79b2a84badbd136eec434e44d14d552c1e88e8`:
```
jq -S -c -M ' ' ~/.odin/config/genesis.json | shasum -a 256
```

### Setup Unit/Daemon file

```bash:
# 1. create daemon file
touch /etc/systemd/system/odin.service

# 2. run:
cat <<EOF >> /etc/systemd/system/odin.service
[UNIT]
Description=Odin daemon
After=network-online.target

[Service]
User=<USER>
ExecStart=/home/<USER>/go/bin/odind start
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
systemctl enable odin.service

# 5. start daemon
systemctl start odin.service
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
odind q bank balances $(odind keys show -a <key-alias>)
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
--details "validators write bios too" \ 
--pubkey $(odind tendermint show-validator) \ 
--moniker $MONIKER_NAME \ 
--chain-id $CHAIN_ID \ 
--fees 2000loki \
--from <key-name>
```

To ensure your validator is active, run:
```
odind q staking validators | grep moniker
```

### Backup critical files
```bash:
priv_validator_key.json
node_key.json
```
