#!/usr/bin/env sh

set -e

export KUBECONFIG="$(pwd)/kind-syncsource.kubeconfig"
../hacks/kind.sh syncsource default "$KUBECONFIG"

export KUBECONFIG="$(pwd)/kind-synctarget.kubeconfig"
../hacks/kind.sh synctarget kcp "$KUBECONFIG"

export KUBECONFIG="$(pwd)/kind-syncer.kubeconfig"
../hacks/kind.sh syncer kcp "$KUBECONFIG"

kcp_config="$(pwd)/kcp-synctarget.kubeconfig"
../hacks/kcp.sh "$KUBECONFIG" "$kcp_config"

export KUBECONFIG="$kcp_config"

# create a workspace

k create-workspace a --ignore-existing

k ws :root:a

# create an empty apiexport in the workspace
k create -f apiexport.yaml

# export in ws
k get apiexport


