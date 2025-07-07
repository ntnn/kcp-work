#!/usr/bin/env sh

set -e

kind get clusters | grep -q kind-kcp \
    || kind create cluster --name kcp

kapps "" kind-kcp default

helm repo add jetstack https://charts.jetstack.io
helm repo add kcp-dev https://kcp-dev.github.io/helm-charts/
helm repo update

helm upgrade \
  --install \
  --wait \
  --namespace kcp \
  --create-namespace \
  --version v0.9.3 \
  --values "$(dirname "$0")/kcp.yaml" \
  kcp kcp-dev/kcp

kind_url="$(yq -r '.clusters[0].cluster.server' "$KUBECONFIG")"
kcp_port="$(yq -r '.externalPort' "$(dirname "$0")/kcp.yaml")"
cat > "$kcp_config" <<EOF
apiVersion: v1
kind: Config
clusters:
  - cluster:
      insecure-skip-tls-verify: true
      server: "${kind_url%:*}:${kcp_port}/clusters/root"
    name: kind-kcp
contexts:
  - context:
      cluster: kind-kcp
      user: kind-kcp
    name: kind-kcp
current-context: kind-kcp
users:
  - name: kind-kcp
    user:
      token: admin-token
EOF
