#!/usr/bin/env sh

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <kind kube config input> <kcp kube config output>"
    exit 1
fi

export KUBECONFIG="$1"
kcp_config="$2"

helm repo add jetstack https://charts.jetstack.io
helm repo add kcp-dev https://kcp-dev.github.io/helm-charts/
helm repo update

kubectl apply -n cert-manager \
    -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.crds.yaml

helm upgrade \
  --install \
  --wait \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  cert-manager jetstack/cert-manager

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
