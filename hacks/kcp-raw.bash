#!/usr/bin/env bash

cd "$(dirname "$0")/.."
basedir="$(pwd)"
cd kcp

rm -rf "$basedir/.kcp"
mkdir -p "$basedir/.kcp"

kcp_args=(
    "start"
    --root-directory="$basedir/.kcp"
    --etcd-servers='http://localhost:2380'
    -v=2
)

start_etcd() {
    ETCD_UNSUPPORTED_ARCH="arm64" /opt/homebrew/opt/etcd/bin/etcd \
        --name=kcp-etcd \
        --data-dir="$basedir/.kcp/etcd" \
        --log-outputs="$basedir/etcd.log"
}

start_etcd &
# TODO poll for etcd to be ready
sleep 5

{
    case "$1" in
        (dlv) dlv debug --listen 127.0.0.1:9999 --headless ./cmd/kcp -- ${kcp_args[@]} ;;
        (*) go run ./cmd/kcp ${kcp_args[@]} ;;
    esac
} 2>&1 | tee "$basedir/kcp.log"
