# INSTRUCTION FOR UPDATE YOUR NODE TO VERSION 0.6.0

#### 1. Create folders for cosmovisor

Create folders .odin/cosmovisor/upgrades/v0.6.0/bin.
```bash
mkdir -p .odin/cosmovisor/upgrades/v0.6.0/bin
```

#### 2. Build new binary odind

Build new binary odind:
```bash
git clone https://github.com/ODIN-PROTOCOL/odin-core.git

cd odin-core
git fetch --tags
git checkout v0.6.0

make all
```

Copy new binary to cosmovisor folder:
```bash
cp /home/<USER>/go/bin/odind /home/<USER>/.odin/cosmovisor/upgrades/v0.6.0/bin/odind
```