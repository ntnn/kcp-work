#!/usr/bin/env sh

export KUBECONFIG="$(find-kubeconfig)"

while ! k get ws; do
  echo "Waiting for API to be ready"
  sleep 1
done

max="${1:-1}"

for i in $(seq 1 $max); do
    echo "$i"
    k apply -f org-ws.yaml
    sleep 3
    echo "workspace id: $(k get ws a-space -o jsonpath='{.spec.cluster}')"
    k delete -f org-ws.yaml
    sleep 3
done

