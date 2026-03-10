# Build librespot with cargo in builder stage
FROM rust:slim-trixie@sha256:d6782f2b326a10eaf593eb90cafc34a03a287b4a25fe4d0c693c90304b06f6d7 AS builder

# renovate: datasource=github-releases depName=librespot packageName=librespot-org/librespot
ARG LIBRESPOT_VERSION=0.8.0
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y \
        && apt-get install -y libasound2-dev pkg-config libssl-dev
RUN cargo install librespot --version "${LIBRESPOT_VERSION}" --locked

# Install snapcast and copy librespot binary from builder stage
FROM debian:trixie-slim@sha256:1d3c811171a08a5adaa4a163fbafd96b61b87aa871bbc7aa15431ac275d3d430

# renovate: datasource=github-releases depName=snapcast packageName=badaix/snapcast
ARG SNAPCAST_VERSION=0.35.0
COPY --from=builder /usr/local/cargo/bin/librespot /usr/local/bin/
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y \
        && apt-get install -y wget alsa-utils \
        && wget https://github.com/badaix/snapcast/releases/download/v${SNAPCAST_VERSION}/snapserver_${SNAPCAST_VERSION}-1_amd64_trixie.deb \
        && apt-get install -y ./snapserver_${SNAPCAST_VERSION}-1_amd64_trixie.deb \
        && apt-get clean && rm -fR /var/lib/apt/lists
CMD ["/usr/bin/snapserver"]
