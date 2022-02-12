FROM alpine AS build-deps

LABEL maintainer="Tony <i@tony.moe>"

ENV NINJA_VERSION 1.10.2
ENV LIBTORRENT_VERSION 1.2.15
ENV QBITTORRENT_VERSION 4.4.0

RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    automake \
    boost-dev \
    build-base \
    cmake \
    curl \
    git \
    icu-dev \
    libexecinfo-dev \
    libtool \
    linux-headers \
    openssl-dev \
    perl \
    pkgconf \
    python3 \
    python3-dev \
    qt5-qtbase-dev \
    qt5-qtsvg-dev \
    qt5-qttools-dev \
    re2c \
    tar \
    zlib-dev \
  \
  && mkdir /usr/src \
  && cd /usr/src \
  \
  && mkdir ninja \
  && curl -sL https://github.com/ninja-build/ninja/archive/v${NINJA_VERSION}.tar.gz \
    | tar --strip-components 1 -C ninja -xzf - \
  && cd ninja \
  && cmake -Wno-dev -B build \
    -D CMAKE_CXX_STANDARD=17 \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
  && cmake --build build \
  && cmake --install build \
  && cd .. \
  \
  && mkdir libtorrent \
  && curl -sL https://github.com/arvidn/libtorrent/archive/v${LIBTORRENT_VERSION}.tar.gz \
    | tar --strip-components 1 -C libtorrent -xzf - \
  && cd libtorrent \
  && cmake -Wno-dev -G Ninja -B build \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_STANDARD=17 \
    -D CMAKE_INSTALL_LIBDIR=lib \
    -D CMAKE_INSTALL_PREFIX=/usr/src/build-deps \
  && cmake --build build \
  && cmake --install build \
  && cd .. \
  \
  && mkdir qbittorrent \
  && curl -sL https://github.com/qbittorrent/qBittorrent/archive/release-${QBITTORRENT_VERSION}.tar.gz \
    | tar --strip-components 1 -C qbittorrent -xzf - \
  && cd qbittorrent \
  && cmake -Wno-dev -G Ninja -B build \
    -D CMAKE_BUILD_TYPE=release \
    -D CMAKE_CXX_STANDARD=17 \
    -D CMAKE_CXX_STANDARD_LIBRARIES=/usr/lib/libexecinfo.so \
    -D CMAKE_INSTALL_PREFIX=/usr/src/build-deps \
    -D GUI=OFF \
  && cmake --build build \
  && cmake --install build \
  && cd .. \
  \
  && strip build-deps/bin/qbittorrent-nox

FROM alpine

COPY --from=build-deps /usr/src/build-deps /usr/local

RUN runDeps=$( \
    scanelf --needed --nobanner --format '%n#p' /usr/local/bin/qbittorrent-nox \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  ) \
  && apk add --no-cache --virtual .qbittorrent-rundeps $runDeps

COPY config /qBittorrent/config

VOLUME ["/qBittorrent/config", "/watch", "/downloads"]
EXPOSE 8080 51413 51413/udp 

CMD ["qbittorrent-nox", "--profile=/"]
