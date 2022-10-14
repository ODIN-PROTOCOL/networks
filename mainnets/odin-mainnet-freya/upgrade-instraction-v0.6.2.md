# INSTRUCTION FOR UPDATE YOUR NODE TO VERSION 0.6.2

#### 1. Update go version to 1.8
Skip this step, if `go` already updated

Uninstall oll version:
```bash 
sudo rm -rf /usr/local/go
```

Install new version:
```bash:
wget https://golang.org/dl/go1.18.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz

cat <<EOF >> ~/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile
go version
```

Output should be: `go version go1.18.1 linux/amd64`

#### 2. Create folders for cosmovisor

Create folders .odin/cosmovisor/upgrades/v0.6.2/bin.
```bash
mkdir -p .odin/cosmovisor/upgrades/v0.6.2/bin
```

#### 3. Build new binary odind

Build new binary odind:
```bash
git clone https://github.com/ODIN-PROTOCOL/odin-core.git

cd odin-core
git fetch --tags
git pull
git checkout v0.6.2

make all
```

Copy new binary to cosmovisor folder:
```bash
cp /home/<USER>/go/bin/odind /home/<USER>/.odin/cosmovisor/upgrades/v0.6.2/bin/odind
```

#### 4. Restart yoda service (for Oracle Validators only)

Check if yoda updated
```bash
yoda version
```

Output should be: `0.6.2`


Restart yoda
```bash
sudo systemctl restart yoda
```
