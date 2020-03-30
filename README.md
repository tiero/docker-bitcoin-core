# docker-bitcoin-core
Docker image for Bitcoin Core 0.19 inspired by [ruimarinho/docker-bitcoin-core](https://github.com/ruimarinho/docker-bitcoin-core). Supports armv7 architectures

Public image [Docker Hub](https://hub.docker.com/r/tiero/bitcoin-core)


## Tags

* `arm`, `amd64`, `latest` [Dockerfile](https://github.com/tiero/docker-bitcoin-core/blob/master/Dockerfile) 



## Usage

This image contains the main binaries from the Bitcoin Core project - `bitcoind`, `bitcoin-cli` and `bitcoin-tx`. It behaves like a binary, so you can pass any arguments to the image and they will be forwarded to the `bitcoind` binary:

```sh
$ docker run --rm -it tiero/bitcoin-core -printtoconsole -regtest=1 
```

You can also mount a directory in a volume under `/home/bitcoin/.bitcoin` in case you want to access it on the host:

```sh
$ docker run -v ${PWD}/data:/home/bitcoin/.bitcoin -it --rm tiero/bitcoin-core -printtoconsole -regtest=1
```

You can optionally create a service using `docker-compose`:

```yml
bitcoin-core:
  image: tiero/bitcoin-core
  command:
    -printtoconsole
    -regtest=1
```
