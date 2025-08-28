#!/usr/bin/env bash

kconfig="$1"
ws="$2"

kubectl --kubeconfig "$1" config set-credentials kcp-oidc \
    --exec-api-version=client.authentication.k8s.io/v1 \
    --exec-interactive-mode=Never \
    --exec-command=kubectl \
    --exec-arg=oidc-login \
    --exec-arg=get-token \
    --exec-arg=--oidc-issuer-url=https://127.0.0.1:5557 \
    --exec-arg=--oidc-client-id=kcp \
    --exec-arg=--certificate-authority="/opt/homebrew/etc/pki/issued/dex2.crt" \
    --exec-arg=--oidc-extra-scope=email \
    --exec-arg=--username=admin@example.com \
    --exec-arg=--password=admin

kubectl --kubeconfig "$1" config set-cluster "$2" \
    --server "https://127.0.0.1:6443/clusters/$2" \
    --certificate-authority="/opt/homebrew/etc/pki/issued/kcp.crt"

kubectl --kubeconfig "$1" config set-context "$2" \
    --cluster="$2" \
    --user=kcp-oidc

kubectl --kubeconfig "$1" config use-context "$2"
