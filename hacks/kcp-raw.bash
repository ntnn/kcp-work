#!/usr/bin/env bash

cd "$(dirname "$0")/.."
source ./hacks/.env
basedir="$(pwd)"

echo refreshing etcd
./hacks/etcd.bash clean-data


kcp_args=(
    "start"
    --root-directory="$basedir/.kcp"
    --etcd-servers='http://localhost:2380'
    -v=2

    --bind-address=127.0.0.1
    --tls-cert-file=/opt/homebrew/etc/pki/issued/kcp.crt
    --tls-private-key-file=/opt/homebrew/etc/pki/private/kcp.key
)

dlv=false
for arg in "$@"; do
    case "$arg" in
        (dex)
            kcp_args+=(
            )
            ;;
        (dlv) dlv=true;;
    esac
done

{
    if [[ "$dlv" == true ]]; then
        dlv debug --listen 127.0.0.1:9999 --headless ./kcp/cmd/kcp -- ${kcp_args[@]}
    else
        go run ./kcp/cmd/kcp ${kcp_args[@]}
    fi
} 2>&1 | tee "$basedir/kcp.log"
