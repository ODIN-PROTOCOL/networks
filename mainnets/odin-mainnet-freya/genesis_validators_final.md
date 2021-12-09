# Gentx Validator Final Steps

# Mainnet begins at 2021-12-09T12:00:00.075067653Z

### Set minimum gas fees
```
perl -i -pe 's/^minimum-gas-prices = .+?$/minimum-gas-prices = "0.0125loki"/' ~/.odin/config/app.toml
```

### Add persistent peers
Provided is a small list of peers, however more can be found the `peers.txt` file
```bash:
PEERS="3c9f836af6e8b00e77ca5792d5a92e2fea8d3f20@116.202.169.136:26656,46fd2ff68ac8128ce04aed6584fa67b048c228ee@162.55.214.187:26766,9d16b1ce74a34b869d69ad5fe34eaca614a36ecd@35.241.238.207:26656,02e905f49e1b869f55ad010979931b542302a9e6@35.241.221.154:26656,aa738c14df142b0119f90bcadfa1f747d5e32b25@130.211.208.2:26656,fa9bb933a7cd51675b903a4565d0c59379500be7@63.209.32.254:26656,0165cd0d60549a37abb00b6acc8227a54609c648@34.79.179.216:26656"
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

# 4. enable service
systemctl enable odin.service

# 5. start daemon
systemctl start odin.service
```

In order to watch the service run, you can do the following:
```
journalctl -u odin.service -f
```

The expected output is as follows:
```
10:33PM INF Starting Node service impl=Node
10:33PM INF Genesis time is in the future. Sleeping until then... genTime=2021-12-09T12:00:00Z
10:33PM INF Starting pprof server laddr=localhost:6060
```

### Backup critical files
```bash:
priv_validator_key.json
node_key.json
```
