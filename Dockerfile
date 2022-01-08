FROM debian:bullseye-slim
COPY entrypoint.sh /
RUN apt-get update \
&& apt-get install -y wget build-essential libasound2-dev pkg-config alsa-utils \
&& wget https://sh.rustup.rs -O install_cargo.sh \
&& sh install_cargo.sh -y \
&& $HOME/.cargo/bin/cargo install librespot \
&& wget https://github.com/badaix/snapcast/releases/download/v0.26.0/snapserver_0.26.0-1_amd64.deb -O snapcast-server.deb \
&& apt-get install -y ./snapcast-server.deb \
&& apt-get purge -y wget libasound2-dev pkg-config build-essential \
&& apt-get autoremove --purge -y \
&& apt-get clean \
&& rm snapcast-* install_cargo.sh \
&& rm -r /root/.rustup
CMD /entrypoint.sh
