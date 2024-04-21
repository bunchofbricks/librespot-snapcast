# Build librespot with cargo in builder stage
FROM rust:slim-bookworm AS builder
ARG LIBRESPOT_VERSION=0.4.2
RUN cargo install librespot --version "${LIBRESPOT_VERSION}" --no-default-features

# Install snapcast and copy librespot binary from builder stage
FROM debian:bookworm-slim
COPY --from=builder /usr/local/cargo/bin/librespot /usr/local/bin/
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y \
&& apt-get install -y wget alsa-utils unzip \
&& wget https://github.com/badaix/snapcast/releases/download/v0.28.0/snapcast_0.28.0_amd64-debian-bookworm.zip \
&& unzip snapcast_0.28.0_amd64-debian-bookworm.zip \
&& apt-get install -y ./snapserver_0.28.0-1_amd64.deb \
&& apt-get clean && rm -fR /var/lib/apt/lists
CMD ["/usr/bin/snapserver"]
