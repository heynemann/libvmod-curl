FROM debian:jessie

RUN \
  useradd -r -s /bin/false varnishd

# Install Varnish source build dependencies.
RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    automake \
    build-essential \
    ca-certificates \
    curl \
    libedit-dev \
    libjemalloc-dev \
    libncurses-dev \
    libpcre3-dev \
    libtool \
    pkg-config \
    python-docutils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Varnish from source, so that Varnish modules can be compiled and installed.
ENV VARNISH_VERSION=4.1.9
ENV VARNISH_SHA256SUM=22d884aad87e585ce5f3b4a6d33442e3a855162f27e48358c7c93af1b5f2fc87
ENV VARNISH_URL=http://varnish-cache.org/_downloads/varnish-$VARNISH_VERSION.tgz
RUN mkdir -p /usr/local/src
WORKDIR /usr/local/src
  
RUN echo "Downloading varnish $VARNISH_VERSION from $VARNISH_URL..." && curl -sfLO $VARNISH_URL
RUN echo "${VARNISH_SHA256SUM} varnish-$VARNISH_VERSION.tgz" | sha256sum -c -

RUN tar -xzf varnish-$VARNISH_VERSION.tgz

WORKDIR /usr/local/src/varnish-$VARNISH_VERSION

RUN ./autogen.sh && \
  ./configure && \
  make && \
  make install && \
  ldconfig

RUN rm /usr/local/src/varnish-$VARNISH_VERSION.tgz

COPY scripts/start-varnishd.sh /usr/local/bin/start-varnishd
RUN chmod +x /usr/local/bin/start-varnishd

ENV VARNISH_PORT 80
ENV VARNISH_MEMORY 100m
ENV VARNISH_DAEMON_OPTS ""

EXPOSE 80

WORKDIR /tmp
RUN curl -sfLO https://curl.haxx.se/download/curl-7.59.0.tar.gz
RUN tar xvzf curl-7.59.0.tar.gz
RUN cd curl* && ./configure && make && make install

CMD ["/usr/local/bin/start-varnishd"]
