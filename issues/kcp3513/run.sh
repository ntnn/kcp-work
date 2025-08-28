#!/usr/bin/env bash

set -euo pipefail

alias k=kubectl

./hacks/create-ws ":root:provider"

k apply -f ./hacks/dex-ws-authconfig.yaml

./hacks/create-ws ":root:consumer" dex-ws

k --context root:provider apply -f https://raw.githubusercontent.com/kcp-dev/kcp/refs/heads/main/test/e2e/virtual/apiexport/crd_cowboys.yaml

k --context root:provider get crd cowboys.wildwest.dev -o yaml \
    | k kcp crd snapshot -f- --prefix today \
    | k --context root:provider apply -f-

k --context root:provider apply -f ./issues/kcp3513/apiexport.yaml

# k --context root:provider apply -f ./issues/kcp3513/provider-all-authenticated.yaml

consumer_cluster_id=$(k get ws consumer -o jsonpath='{.spec.cluster}')
yq '.subjects[0].name = "system:cluster:'$consumer_cluster_id'"' \
    ./issues/kcp3513/provider-only-consumer-ws.yaml \
    | k --context root:provider apply -f -

k --context root:consumer create ns default # ??
k --context root:consumer apply -f ./issues/kcp3513/consumer.yaml

./hacks/dex-oidc-genconfig.bash oidc.kubeconfig root:consumer

k --kubeconfig oidc.kubeconfig apply -f ./issues/kcp3513/apibinding.yaml

sleep 1

k --context root:consumer get apibindings
k --context root:consumer get cowboys.wildwest.dev
