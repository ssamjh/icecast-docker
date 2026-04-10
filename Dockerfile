# syntax=docker/dockerfile:1

ARG ICECAST_VERSION=2.5.0
ARG IGLOO_VERSION=0.9.5

FROM alpine:3.23 AS builder

ARG ICECAST_VERSION
ARG IGLOO_VERSION

RUN apk add --no-cache \
    build-base \
    autoconf \
    automake \
    libtool \
    libxml2-dev \
    libxslt-dev \
    openssl-dev \
    curl-dev \
    libogg-dev \
    libvorbis-dev \
    libtheora-dev \
    speex-dev \
    rhash-dev \
    wget

WORKDIR /src
RUN wget -qO libigloo.tar.gz \
      "https://downloads.xiph.org/releases/igloo/libigloo-${IGLOO_VERSION}.tar.gz" \
    && tar -xzf libigloo.tar.gz \
    && rm libigloo.tar.gz \
    && cd libigloo-${IGLOO_VERSION} \
    && ./configure --prefix=/usr/local \
    && make -j"$(nproc)" \
    && make DESTDIR=/install install \
    && make install

RUN wget -qO icecast.tar.gz \
      "https://downloads.xiph.org/releases/icecast/icecast-${ICECAST_VERSION}.tar.gz" \
    && tar -xzf icecast.tar.gz \
    && rm icecast.tar.gz

WORKDIR /src/icecast-${ICECAST_VERSION}
RUN ./configure \
        --prefix=/usr/local \
        --sysconfdir=/etc/icecast \
        --localstatedir=/var \
    && make -j"$(nproc)" \
    && make DESTDIR=/install install

FROM alpine:3.23

RUN apk add --no-cache \
    libxml2 \
    libxslt \
    openssl \
    curl \
    libogg \
    libvorbis \
    libtheora \
    speex \
    rhash

COPY --from=builder /install/ /

RUN mkdir -p /etc/icecast /var/log/icecast /var/run/icecast

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget -qO- http://localhost:8000/ || exit 1

CMD ["icecast", "-c", "/etc/icecast/icecast.xml"]
