# Gentx Validator Final Steps

### Set minimum gas fees
perl -i -pe 's/^minimum-gas-prices = .+?$/minimum-gas-prices = "0.0125loki"/' ~/.odin/config/app.toml

### Add persistent peers
```bash:
PEERS = TBD
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.odin/config/config.toml
```

### Download genesis file
```bash:
curl TBD > ~/.odin/config/genesis.json
```

Verify the hash `TBD`:
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
User=root
ExecStart=/root/go/bin/odind start
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

### Backup critical files
```bash:
priv_validator_key.json
node_key.json
```
