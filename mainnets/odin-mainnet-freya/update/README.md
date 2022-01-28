# ODIN MAINNET FREYA
## Update version

### 1) Stop node
```bash:
systemctl stop odin.service
```

### 2) Install latest Odind from source

#### 1. Pull changes

* Navigate to current repository folder.
```shell
cd odin-core
```

* Pull the latest version of the repository
```shell
git pull
```

* Checkout latest tag
```shell
git fetch --tags
git checkout v0.3.1
```
#### 2. Build the new version of CLI
```shell
make all
```
	
To confirm that the installation was successful, you can run:

```bash:
odind version
```
Output should be: `v0.3.1`

### 3) Clean old state

```bash:
odind unsafe-reset-all
```

# Download and extract snapshot
```bash:
cd ~/
wget https://share.blockpane.com/odin-mainnet-freya_20220126_default_kv_v0.3.1.tar.xz
xz -d odin-mainnet-freya_20220126_default_kv_v0.3.1.tar.xz
mv odin-mainnet-freya_20220126_default_kv_v0.3.1.tar .odin
tar xvf odin-mainnet-freya_20220126_default_kv_v0.3.1.tar
rm odin-mainnet-freya_20220126_default_kv_v0.3.1.tar
```

### 4) Rerun node
```bash:
systemctl daemon-reload
systemctl start odin.service
```
