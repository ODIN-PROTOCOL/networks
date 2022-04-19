# CREATION IBC MODULE INSTRUCTION

## 1. Install Ignite CLI

Follow the instruction [here](https://docs.ignite.com/guide/install.html) to install CLI.

## 2. Create module with ibc

```bash
ignite scaffold module [module-name] --ibc
```

## 3. Create txs to interact with Odin chain

```bash
ignite scaffold band [tx-name] --module [module-name]
```

## 4. Update keys

In the `x/[module-name]/type/key.go` file update `Version` and `PortID` variables:
```go
package types

const(
	// Version defines the current version the IBC module supports
	Version = "oracle-1"

	// PortID is the default port id that module binds to
	PortID = "oracle"
)
```

## 5. Specify needed calldata and result

In the `proto/[module-name]/[tx-name].proto` file change `[tx-name]Calldata` and `[tx-name]Result` structures.
(examples in ibc-structures)

## 6. Fix cli

In the `x/[module-name]/client/cli/tx_[tx-name].go` file change old parameters and flags for new calldata.

## 7. Create IBC connection between your chain and Odin chain
Configure ibc relayer:
```bash 
ignite relayer configure -a \
--source-rpc "https://node.odin-freya-website.odinprotocol.io/mainnet/a" \
--source-port "oracle" \
--source-gasprice "0.0125loki" \
--source-gaslimit 5000000 \
--source-prefix "odin" \
--source-version "oracle-1" \
--target-rpc "http://localhost:26657" \
--target-faucet "http://localhost:4500" \
--target-port "oracle" \
--target-gasprice "0.0125stake" \
--target-gaslimit 3000000 \
--target-prefix "cosmos"  \
--target-version "oracle-1"
```

Check tokens on source and target accounts.
Create IBC connection:
```bash 
ignite relayer connect
```
