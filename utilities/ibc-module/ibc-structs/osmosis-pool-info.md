# Osmosis pool info structs

````protobuf
syntax = "proto3";

message Pools {
    uint64 pool_id = 1;
    string price = 2;
    string liquidity = 3;
    string liquidity_atom = 4;
}

message OsmosisPoolInfoCallData {
  string base_symbol = 1;
  string quote_symbol = 2;
}

message OsmosisPoolInfoResult {
  repeated Pools numbers = 1;
}


````