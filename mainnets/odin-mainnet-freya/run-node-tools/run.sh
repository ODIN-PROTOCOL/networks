#!/bin/bash

rm -f ./genesis.json

wget https://raw.githubusercontent.com/ODIN-PROTOCOL/networks/master/mainnets/odin-mainnet-freya/final_genesis.json -O genesis.json

docker-compose down -v --remove-orphans

docker-compose pull

docker-compose -f ./docker-compose.yaml up -d