FROM ubuntu:bionic AS build-stage

ARG SYSCOIN_VERSION=v4.2.0

ARG DEBIAN_FRONTEND=noninteractive

RUN set -xe; \
  apt-get update; apt-get install -yq \
  # build tools
  automake autotools-dev bsdmainutils build-essential cmake git libtool pkg-config python3 software-properties-common \
  # libs
  libboost-chrono-dev libboost-filesystem-dev libboost-system-dev libboost-test-dev libboost-thread-dev libcurl4-openssl-dev libevent-dev libgmp3-dev libssl-dev; \
  # libdb4.8
  add-apt-repository -y ppa:bitcoin/bitcoin; \
  apt-get update; apt-get install -yq \
  libdb4.8-dev libdb4.8++-dev; \
  # syscoin
  git clone --single-branch --branch ${SYSCOIN_VERSION} https://github.com/syscoin/syscoin.git; cd syscoin; \
  ./autogen.sh; ./configure --disable-tests --prefix=/usr/local; \
  make -j$(nproc) src/syscoind src/syscoin-cli; make install src/syscoind src/syscoin-cli;

FROM ubuntu:bionic

COPY --from=build-stage /lib/* /lib/
COPY --from=build-stage /usr/lib/* /usr/lib/
COPY --from=build-stage /usr/local/lib/* /usr/local/lib/
COPY --from=build-stage /usr/local/bin/syscoin* /usr/local/bin/

RUN mkdir -p /root/.syscoin

COPY syscoin.conf /root/.syscoin/

WORKDIR /root

VOLUME [ "/root/.syscoin" ]

EXPOSE 8369 30303

CMD [ "syscoind" ]