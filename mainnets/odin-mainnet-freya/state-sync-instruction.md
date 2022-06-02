# STATE SYNC INSTRUCTION

### 1. Change node config

Open file ~/.odin/config/config.toml

Set fields in section "statesync":
1. enable = true
2. trust_hash = "6E8017D2664C3838805F0EFFCC0243AE9B3ED468CD71975419AA164F745AAD24"
3. trust_height = 2528200
4. rps_servers = "http://34.79.179.216:26657,http://34.140.252.7:26657,http://35.241.221.154:26657,http://35.241.238.207:26657"

Set fields in main section:
1. fast_sync = false

### 2. Clean data directory

```shell
odind unsafe-reset-all
```

*you also may save your state before(just in case)
```shell
sudo cp -r ~/.odin/data ~/.odin/data_save
```

### 3. Restart your node

```shell
sudo systemctl restart cosmovisor
```