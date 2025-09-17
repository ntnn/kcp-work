#!/usr/bin/env bash

cd "$(dirname $0)/.."

docker kill dex
docker pull ghcr.io/dexidp/dex

docker run --name dex -it --rm --detach \
    -p 5557:5557 \
    -v ./hacks/dex.yaml:/dex.yaml:ro \
    -v /opt/homebrew/etc/pki:/pki:ro \
    ghcr.io/dexidp/dex \
    dex serve /dex.yaml
