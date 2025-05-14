#!/usr/bin/env bash

cd "$(dirname "$0")/.."
source ./hacks/.env
basedir="$(pwd)"

check_etcd() {
    curl --fail http://localhost:2379/readyz
}

start_etcd() {
    ETCD_UNSUPPORTED_ARCH="arm64" /opt/homebrew/opt/etcd/bin/etcd \
        --name=kcp-etcd \
        --data-dir="$basedir/.kcp/etcd" \
        --log-outputs="$basedir/etcd.log"
}

kill_etcd() {
    pkill etcd
}

while check_etcd; do
    kill_etcd
done

rm -rf "$basedir/.kcp"
mkdir -p "$basedir/.kcp"

start_etcd &

while ! check_etcd; do
    sleep 1
done
trap kill_etcd EXIT

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
                --oidc-issuer-url='https://127.0.0.1:5556/dex'
                --oidc-client-id=kcp
                --oidc-ca-file="/opt/homebrew/etc/pki/ca.crt"
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
