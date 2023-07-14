## Hardware Requirements
* **Minimal**
    * 4 GB RAM
    * 200 GB SSD
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
wget https://golang.org/dl/go1.18.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz
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
git clone https://github.com/ODIN-PROTOCOL/odin-core.git
```
* Checkout latest tag
```shell
cd odin-core
git fetch --tags
git checkout v0.6.2
```
#### 2. Install ODIN
```shell
make all
```
	
To confirm that the installation was successful, you can run:

```bash:
odind version
```
Output should be: `v0.6.2`

##### Init node 

```bash
odind init <validator-moniker>
```

#### 3. Install Cosmovisor

##### Clone git repo:
```bash
git clone https://github.com/cosmos/cosmos-sdk.git
cd cosmos-sdk
git checkout cosmovisor/v1.3.0
make cosmovisor
```

##### Move cosmovisor to GOPATH:
```bash
cp cosmovisor/cosmovisor ~/go/bin/cosmovisor
```

##### To confirm that the installation was successful, you can run:

```bash
cosmovisor version
```
Output should be: `v1.3.0`

##### Set environment variables

```bash
export DAEMON_HOME=/home/<USER>/.odin
export DAEMON_NAME=odind
```

##### Init cosmovisor

```bash
cosmovisor init ~/go/bin/odind
```

### Generate keys

```bash
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

## Validator Setup Instructions

### Set minimum gas fees
```bash
perl -i -pe 's/^minimum-gas-prices = .+?$/minimum-gas-prices = "0.0125loki"/' ~/.odin/config/app.toml
```

### Add persistent peers
Provided is a small list of peers, however more can be found the `peers.txt` file
```bash
PEERS="4edb332575e5108b131f0a7c0d9ac237569634ad@35.195.4.110:26656,417c2df701780c7f8751bc4a298411374082ef9e@34.78.138.110:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.odin/config/config.toml
```

### Download genesis file
```bash
curl https://storage.googleapis.com/odin-testnet-backup/testnet-genesis.json > ~/.odin/config/genesis.json
```

### Setup Unit/Daemon file

```bash
# 1. create daemon file
touch /etc/systemd/system/cosmovisor.service

# 2. run:
cat <<EOF >> /etc/systemd/system/cosmovisor.service
[Unit]
Description=Odin Cosmovisor Daemon
After=network-online.target

[Service]
User=<USER>
ExecStart=/home/<USER>/go/bin/cosmovisor run start
Restart=on-failure
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_HOME=/home/<USER>/.odin"
Environment="DAEMON_NAME=odind"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

[Install]
WantedBy=multi-user.target
EOF

# 3. reload the daemon
systemctl daemon-reload

# 4. enable service - this means the service will start up 
# automatically after a system reboot
systemctl enable cosmovisor.service

# 5. start daemon
systemctl start cosmovisor.service
```

In order to watch the service run, you can do the following:
```bash
journalctl -u cosmovisor.service -f
```

Congratulations! You now have a full node. Once the node is synced with the network, 
you can then make your node a validator.


### Create validator
1. Transfer funds to your validator address. A minimum of 1 ODIN (1000000loki) is required to start a validator.

2. Confirm your address has the funds.

```bash
odind q bank balances $(odind keys show -a <key-alias>)
```

3. Run the create-validator transaction
**Note: 1,000,000 loki = 1 ODIN, so this validator will start with 1 ODIN**

```bash
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
```bash
odind q staking validators | grep moniker
```

### Backup critical files
```bash
priv_validator_key.json
node_key.json
```

### Data backup
You can download full data backup [here](https://storage.googleapis.com/odin-testnet-backup/data-backup-2023-6-29.tar.gz)
