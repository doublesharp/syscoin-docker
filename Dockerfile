FROM ubuntu:bionic AS build-stage

ARG SYSCOIN_VERSION=4.2.2
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

COPY entrypoint.sh /usr/local/bin/
COPY syscoin.conf /syscoin/

RUN useradd -ms /bin/bash syscoin
USER syscoin

RUN mkdir -p /home/syscoin/.syscoin

WORKDIR /home/syscoin

VOLUME [ "/home/syscoin/.syscoin" ]

EXPOSE 8369 30303

ENTRYPOINT [ "entrypoint.sh" ]

CMD [ "syscoind" ]