# Build librespot with cargo in builder stage
FROM rust:slim-bookworm AS builder
ARG LIBRESPOT_VERSION=0.6.0
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y \
&& apt-get install -y libasound2-dev pkg-config
RUN cargo install librespot --version "${LIBRESPOT_VERSION}"

# Install snapcast and copy librespot binary from builder stage
FROM debian:bookworm-slim
COPY --from=builder /usr/local/cargo/bin/librespot /usr/local/bin/
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y \
&& apt-get install -y wget alsa-utils \
&& wget https://github.com/badaix/snapcast/releases/download/v0.31.0/snapserver_0.31.0-1_amd64_bookworm.deb \
&& apt-get install -y ./snapserver_0.31.0-1_amd64_bookworm.deb \
&& apt-get clean && rm -fR /var/lib/apt/lists
CMD ["/usr/bin/snapserver"]
