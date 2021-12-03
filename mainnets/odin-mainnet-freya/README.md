# ODIN MAINNET FREYA

## First part is to submit the gentx. WHICH IS CLOSED NOW.

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
>Prerequisite: go1.15+ required. [ref](https://golang.org/doc/install)
   Append the below lines to the file ${HOME}/.bashrc and execute the command source ${HOME}/.bashrc to reflect in the current Terminal session
   ```shell
   export GOROOT=/usr/lib/go
   export GOPATH=${HOME}/go
   export GOBIN=${GOPATH}/bin
   export PATH=${PATH}:${GOROOT}/bin:${GOBIN}
   ```

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
* Install
```shell
make all
```

### Generate keys

`odind keys add [key_name]`

or

`odind keys add [key_name] --recover` to regenerate keys with your [BIP39](https://github.com/bitcoin/bips/tree/master/bip-0039) mnemonic


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

* Copy the contents of `${HOME}/.odin/config/gentx/gentx-XXXXXXXX.json`.
* Fork the [repository](https://github.com/ODIN-PROTOCOL/networks/)
* Create a file `gentx-{{VALIDATOR_NAME}}.json` under the mainnets/odin-mainnet-freya/gentxs folder in the forked repo, paste the copied text into the file. Find reference file gentx-examplexxxxxxxx.json in the same folder.
* Run `odind tendermint show-node-id` and copy your nodeID.
* Run `ifconfig` or `curl ipinfo.io/ip` and copy your publicly reachable IP address.
* Create a file `peers-{{VALIDATOR_NAME}}.json` under the mainnets/odin-mainnet-freya/peers folder in the forked repo, paste the copied text from the last two steps into the file. Find reference file sample-peers.json in the same folder. (e.g. fd4351c2e9928213b3d6ddce015c4664e6138@3.127.204.206)

* Create a Pull Request to the `master` branch of the [repository](https://github.com/ODIN-PROTOCOL/networks)
>**NOTE:** The Pull Request will be merged by the maintainers to confirm the inclusion of the validator at the genesis.Maximum number of validators - 64. The final genesis file will be published under the file mainnets/odin-mainent-freya/genesis_final.json.

