# Build librespot with cargo in builder stage
FROM rust:slim-bullseye AS builder
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && apt-get -y install build-essential pkg-config curl unzip
 
ARG LIBRESPOT_VERSION=0.4.0

RUN cargo install librespot --version "${LIBRESPOT_VERSION}" --no-default-features

# Install snapcast and copy librespot binary from builder stage
FROM debian:bullseye-slim
COPY --from=builder /usr/local/cargo/bin/librespot /usr/local/bin/
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y \
&& apt-get install -y wget alsa-utils \
&& wget https://github.com/badaix/snapcast/releases/download/v0.26.0/snapserver_0.26.0-1_amd64.deb -O snapcast-server.deb \
&& apt-get install -y ./snapcast-server.deb \
&& apt-get clean && rm -fR /var/lib/apt/lists
CMD ["/usr/bin/snapserver"]
