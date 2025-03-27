#!/usr/bin/env sh

set -e

export KUBECONFIG="$(pwd)/kind.kubeconfig"
../hacks/kcp-kind.sh "$KUBECONFIG"


kcp_config="$(pwd)/kcp.kubeconfig"
../hacks/kcp.sh "$KUBECONFIG" "$kcp_config"

export KUBECONFIG="$kcp_config"


