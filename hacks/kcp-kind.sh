#!/usr/bin/env sh

kind get clusters | grep -q kcp && exit 0

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <kube config output path>" >&2
    exit 1
fi

kind create cluster --config "$(dirname "$0")/kcp-kind.yaml" --kubeconfig "$1" --wait=30s
