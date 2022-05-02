# YODA SETUP INSTRUCTION

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

### Install Yoda from source

#### 1. Clone repository

* Clone git repository
```shell
git clone https://github.com/ODIN-PROTOCOL/odin-core.git
```
* Checkout latest tag
```shell
cd odin-core
git fetch --tags
git checkout v0.3.4
```
#### 2. Install CLI
```shell
make install-yoda
```

To confirm that the installation was successful, you can run:

```bash:
yoda version
```
Output should be: `v0.3.4`

### Create executor

Google Cloud functions: https://github.com/bandprotocol/data-source-runtime/wiki/Setup-Yoda-Runtime-Using-Google-Cloud-Function

AWS lambda: https://github.com/bandprotocol/data-source-runtime/wiki/Setup-Yoda-Runtime-Using-AWS-Lambda 

### Setup yoda

```shell
# enter mnemonic for your validator
echo "place your mnemonic here" \
    | odind keys add supplier --recover --keyring-backend file

yoda config chain-id odin-mainnet-freya

# add validator to yoda config
yoda config validator $(odind keys show supplier -a --bech val --keyring-backend file)

# setup execution endpoint
# place endpoint to your executor from previous step
yoda config executor "rest:place-your-endpoint-here?timeout=10s"

# setup broadcast-timeout to yoda config
yoda config broadcast-timeout "5m"

# setup rpc-poll-interval to yoda config
yoda config rpc-poll-interval "1s"

# setup max-try to yoda config
yoda config max-try 5

yoda keys add reporter

# send odin tokens to reporter
echo "y" | odind tx bank send supplier $(yoda keys list -a) 1000000loki --keyring-backend file --chain-id odin-mainnet-freya --node tcp://localhost:26657

# add reporter to odinchain
echo "y" | odind tx oracle add-reporters $(yoda keys list -a) --from supplier --keyring-backend file --chain-id odin-mainnet-freya --node tcp://localhost:26657

echo "y" | odind tx oracle activate --from supplier --chain-id odin-mainnet-freya --keyring-backend file --node tcp://localhost:26657
```

## Run yoda

Run commands one by one

```bash:
# 1. create daemon file
touch /etc/systemd/system/yoda.service

# 2. run:
cat <<EOF >> /etc/systemd/system/yoda.service
[Unit]
Description=Yoda daemon
After=network-online.target

[Service]
User=<USER>
ExecStart=/home/<USER>/go/bin/yoda run --log-level debug --node tcp://localhost:26657
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
systemctl enable yoda.service

# 5. start daemon
systemctl start yoda.service
```

In order to watch the service run, you can do the following:
```
journalctl -u yoda.service -f
```

