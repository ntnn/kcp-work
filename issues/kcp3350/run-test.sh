#!/usr/bin/env sh

while ! k get ws; do
  echo "Waiting for API to be ready"
  sleep 1
done

max="${1:-1}"
base="$(dirname $(realpath $0))"

for i in $(seq 1 $max); do
    echo "$i"
    k apply -f "$base/org-ws.yaml"
    sleep 3
    echo "workspace id: $(k get ws a-space -o jsonpath='{.spec.cluster}')"
    k delete -f "$base/org-ws.yaml"
    sleep 3
done

