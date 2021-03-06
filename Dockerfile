FROM debian:stable-slim as build

RUN useradd -r bitcoin \
  && apt-get update -y \
  && apt-get install -y curl gnupg

ARG ARCH
ARG OS

ENV BITCOIN_VERSION=0.19.0.1


RUN set -ex \
  && if [ $(uname -m) = "x86_64" ]; then export ARCH=x86_64; export OS=linux-gnu; fi \
  && if [ $(uname -m) = "armv7l" ]; then export ARCH=arm; export OS=linux-gnueabihf; fi \
  && for key in \
    01EA5486DE18A882D4C2684590C8019E36C2E964 \
  ; do \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" || \
      gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" || \
      gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
    done \
  && curl -SLO https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
  && curl -SLO https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-${ARCH}-${OS}.tar.gz \
  && gpg --verify SHA256SUMS.asc \
  && grep " bitcoin-${BITCOIN_VERSION}-${ARCH}-${OS}.tar.gz\$" SHA256SUMS.asc | sha256sum -c - \
  && tar -xzf *.tar.gz -C /opt \
  && rm -rf /opt/bitcoin-${BITCOIN_VERSION}/bin/bitcoin-qt \
  && mv /opt/bitcoin-${BITCOIN_VERSION}/bin/* /usr/local/bin \
  && mv /opt/bitcoin-${BITCOIN_VERSION}/lib/* /usr/local/lib \
  && mkdir -p /home/bitcoin/.bitcoin

FROM debian:stable-slim


ENV BITCOIN_DATA=/home/bitcoin/.bitcoin

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group
COPY --from=build /usr/local /usr/local
COPY --from=build --chown=bitcoin:bitcoin /home/bitcoin /home/bitcoin

USER bitcoin:bitcoin
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/bitcoin/.bitcoin"]

EXPOSE 8332 8333 18332 18333 18443 18444

ENTRYPOINT ["sh","/entrypoint.sh"]

CMD ["bitcoind"]
