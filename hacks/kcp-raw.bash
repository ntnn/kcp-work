#!/usr/bin/env bash

cd "$(dirname "$0")/.."
source ./hacks/.env
basedir="$(pwd)"

echo refreshing etcd
./hacks/etcd.bash clean-data

rm -rf "$basedir/.kcp"
mkdir -p "$basedir/.kcp"

extra_args=()

log_level=2
dlv=false
for arg in "$@"; do
    case "$arg" in
        (log_level=*) log_level=${arg##log_level=};;
        (dlv) dlv=true;;
        (*) extra_args+=( "$arg" )
    esac
done

kcp_args=(
    "start"
    --root-directory="$basedir/.kcp"
    --etcd-servers='http://localhost:2379'
    -v=${log_level}

    --bind-address=127.0.0.1
    # --tls-cert-file=/opt/homebrew/etc/pki/issued/kcp.crt
    # --tls-private-key-file=/opt/homebrew/etc/pki/private/kcp.key

    --feature-gates=CacheAPIs=true,WorkspaceMounts=true
)

echo "starting kcp with '${kcp_args[@]}'"
rm -f kcp.log
{
    if [[ "$dlv" == true ]]; then
        dlv debug --listen 127.0.0.1:9999 --headless ./kcp/cmd/kcp -- ${kcp_args[@]} ${extra_args[@]}
    else
        go run ./kcp/cmd/kcp ${kcp_args[@]} ${extra_args[@]}
    fi
} 2>&1 | tee "$basedir/kcp.log"
