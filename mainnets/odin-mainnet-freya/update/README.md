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
git checkout v0.4.0
```
#### 2. Build the new version of CLI
```shell
make all
```
	
To confirm that the installation was successful, you can run:

```bash:
odind version
```
Output should be: `v0.4.0`

### 3) Rerun node
```bash:
systemctl daemon-reload
systemctl start odin.service
```
