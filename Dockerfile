FROM ubuntu:bionic AS build-stage

ARG SYSCOIN_VERSION=4.2.0
ARG GZ_FILE=syscoin-${SYSCOIN_VERSION}-x86_64-linux-gnu.tar.gz

ARG DEBIAN_FRONTEND=noninteractive

RUN set -xe; \
  apt-get update; \
  apt-get install -yq ca-certificates gpg wget; \
  wget https://github.com/syscoin/syscoin/releases/download/v${SYSCOIN_VERSION}/SHA256SUMS.asc; \
  wget https://github.com/syscoin/syscoin/releases/download/v${SYSCOIN_VERSION}/${GZ_FILE}; \
  gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 79D00BAC68B56D422F945A8F8E3A8F3247DBCBBF; \
  gpg --verify SHA256SUMS.asc; \
  sha256sum --ignore-missing -c SHA256SUMS.asc; \
  mkdir -p /syscoin; tar -xzvf ${GZ_FILE} -C /syscoin --strip-components 1; rm ${GZ_FILE};

FROM ubuntu:bionic

ENV PATH=${PATH}:/syscoin/bin

COPY --from=build-stage /syscoin /syscoin

RUN mkdir -p /root/.syscoin

COPY syscoin.conf /root/.syscoin/

WORKDIR /root

VOLUME [ "/root/.syscoin" ]

EXPOSE 8369 30303

CMD [ "syscoind" ]