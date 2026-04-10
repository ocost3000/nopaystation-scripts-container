FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc make git ca-certificates curl libc6-dev \
 && rm -rf /var/lib/apt/lists/*

# pkg2zip (lusid1 fork)
RUN git clone https://github.com/lusid1/pkg2zip \
 && cd pkg2zip && make && cp pkg2zip /usr/local/bin/

# mktorrent v1.1
RUN git clone https://github.com/Rudde/mktorrent \
 && cd mktorrent && make && make install

# torrent7z — pre-built binary
RUN curl -L https://github.com/BubblesInTheTub/torrent7z/releases/download/1.3/t7z \
    -o /usr/local/bin/t7z && chmod +x /usr/local/bin/t7z


FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-lxml curl wget ca-certificates git file \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/pkg2zip /usr/local/bin/
COPY --from=builder /usr/local/bin/mktorrent /usr/local/bin/
COPY --from=builder /usr/local/bin/t7z /usr/local/bin/

RUN git clone https://github.com/sigmaboy/nopaystation_scripts /scripts

ENV PATH="/scripts:$PATH"

WORKDIR /scripts
