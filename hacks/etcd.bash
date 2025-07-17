#!/usr/bin/env bash

cd "$(dirname "$0")/.."
source ./hacks/.env
basedir="$(pwd)/.etcd"

clean_data=0
for arg in "$@"; do
    case "$arg" in
        (clean-data) clean_data=1;;
    esac
    shift 1
done

check_etcd() {
    curl --fail http://localhost:2379/readyz
}

start_etcd() {
    [[ "$clean_data" -eq 1 ]] && rm -rf "$basedir/data"
    ETCD_UNSUPPORTED_ARCH="arm64" /opt/homebrew/opt/etcd/bin/etcd \
        --name=kcp-raw-etcd \
        --data-dir="$basedir/data" \
        --log-outputs="$basedir/etcd.log"
}

kill_etcd() {
    pkill etcd
}

while check_etcd; do
    kill_etcd
done

# rm -rf "$basedir/"
mkdir -p "$basedir/"

start_etcd &

while ! check_etcd; do
    sleep 1
done
# trap kill_etcd EXIT
