# Build librespot with cargo in builder stage
FROM rust:slim-trixie AS builder
ARG LIBRESPOT_VERSION=0.7.1
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y \
&& apt-get install -y libasound2-dev pkg-config libssl-dev
RUN cargo install librespot --version "${LIBRESPOT_VERSION}"

# Install snapcast and copy librespot binary from builder stage
FROM debian:trixie-slim
ARG SNAPCAST_VERSION=0.33.0
COPY --from=builder /usr/local/cargo/bin/librespot /usr/local/bin/
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y \
&& apt-get install -y wget alsa-utils \
&& wget https://github.com/badaix/snapcast/releases/download/v${SNAPCAST_VERSION}/snapserver_${SNAPCAST_VERSION}-1_amd64_trixie.deb \
&& apt-get install -y ./snapserver_${SNAPCAST_VERSION}-1_amd64_trixie.deb \
&& apt-get clean && rm -fR /var/lib/apt/lists
CMD ["/usr/bin/snapserver"]
