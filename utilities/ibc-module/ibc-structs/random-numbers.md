# Random numbers structs

```protobuf
syntax = "proto3";

message RandomNumbersCallData {
  int64 length = 1;
}

message RandomNumbersResult {
  repeated int64 numbers = 1;
}
```