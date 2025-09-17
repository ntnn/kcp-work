#!/usr/bin/env bash

kubectl \
    oidc-login \
    get-token \
    --oidc-issuer-url=https://127.0.0.1:5557 \
    --oidc-client-id=kcp \
    --certificate-authority="/opt/homebrew/etc/pki/issued/dex2.crt" \
    --oidc-extra-scope=email \
    --username=admin@example.com \
    --password=admin
