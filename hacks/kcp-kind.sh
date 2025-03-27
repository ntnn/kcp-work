#!/usr/bin/env sh

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <cluster name> <cluster template> <kubeconfig output path>" >&2
    exit 1
fi

name="$1"
template="$2"
output="$3"

kind get clusters | grep -q "$name" && exit 0

kind create cluster --name "$name" --config "$(dirname "$0")/kind/$template.yaml" --kubeconfig "$output" --wait=30s
