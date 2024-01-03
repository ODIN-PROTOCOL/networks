FROM geodbodinprotocol/core:v0.7.2

RUN go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
RUN mkdir -p ~/.odin/cosmovisor/genesis/bin
RUN cp /go/bin/odind ~/.odin/cosmovisor/genesis/bin/odind

CMD ["cosmovisor", "run", "start"]