#!/usr/bin/env bash

cd "$(dirname "$0")/.."
source ./hacks/.env
basedir="$(pwd)/.etcd"

clean_data=0
server_restart=0
for arg in "$@"; do
    case "$arg" in
        (clean-data)
            server_restart=1
            clean_data=1
            ;;
        (restart) server_restart=1;;
        (stop) server_stop=1;;
    esac
    shift 1
done

check_etcd() {
    curl --fail http://localhost:2379/readyz
}

start_etcd() {
    mkdir -p "$basedir/"
    [[ "$clean_data" -eq 1 ]] && rm -rf "$basedir/data"
    ETCD_UNSUPPORTED_ARCH="arm64" /opt/homebrew/opt/etcd/bin/etcd \
        --name=kcp-raw-etcd \
        --data-dir="$basedir/data" \
        --log-outputs="$basedir/etcd.log"
}

kill_etcd() {
    while check_etcd; do
        pkill etcd
    done
}

if [[ "$server_stop" -eq 1 ]] || [[ "$server_restart" -eq 1 ]]; then
    kill_etcd
    [[ "$server_stop" -eq 1 ]] && exit
fi

start_etcd &

while ! check_etcd; do
    sleep 1
done
