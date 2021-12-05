# ODIN MAINNET FREYA

## First part is to submit the gentx.This is open until Tuesday, December 7th.

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


## Validator setup instructions for validators participating in the genesis

### GenTx : Will Be Accepting Soon.

* [Install](#installation-steps) odin core application
* Initialize node

```shell
odind init "{{NODE_NAME}}" --chain-id odin-mainnet-freya
```

* Replace the contents of your `${HOME}/.odin/config/genesis.json` with that of mainnets/odin-mainnet-freya/pre_genesis.json.

```shell
wget https://raw.githubusercontent.com/ODIN-PROTOCOL/networks/master/mainnets/odin-mainnet-freya/pre_genesis.json
```
**WARNING: DO NOT PUT MORE THAN 10000000loki or your gentx will be rejected**
```shell
odind add-genesis-account "{{KEY_NAME}}" 10000000loki
odind gentx "{{KEY_NAME}}" 10000000loki \
--chain-id odin-mainnet-freya \
--moniker="{{VALIDATOR_NAME}}" \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.2 \
--commission-rate=0.1 \
--details="XXXXXXXX" \
--security-contact="XXXXXXXX" \
--website="XXXXXXXX"
```

1. Copy the contents of `${HOME}/.odin/config/gentx/gentx-XXXXXXXX.json`.
2. Fork the [repository](https://github.com/ODIN-PROTOCOL/networks/)
3. Create a file `gentx-{{VALIDATOR_NAME}}.json` under the mainnets/odin-mainnet-freya/gentxs folder in the forked repo, paste the copied text into the file. Find reference file gentx-examplexxxxxxxx.json in the same folder.
4. Run `odind tendermint show-node-id` and copy your nodeID.
5. Run `ifconfig` or `curl ipinfo.io/ip` and copy your publicly reachable IP address.
6. Create a file `peers-{{VALIDATOR_NAME}}.json` under the mainnets/odin-mainnet-freya/peers folder in the forked repo, paste the copied text from the last two steps into the file. Find reference file sample-peers.json in the same folder. (e.g. fd4351c2e9928213b3d6ddce015c4664e6138@3.127.204.206)

7. Create a Pull Request to the `master` branch of the [repository](https://github.com/ODIN-PROTOCOL/networks)
>**NOTE:** The Pull Request will be merged by the maintainers to confirm the inclusion of the validator at the genesis.Maximum number of validators - 100. The final genesis file will be published under the file mainnets/odin-mainent-freya/genesis_final.json.


## Validator run instruction
### TODO
