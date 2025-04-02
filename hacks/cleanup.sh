#!/usr/bin/env sh

kind get clusters | xargs -rt kind delete clusters
find "$(dirname "$0")/.." -name "*.kubeconfig" -o -name 'kubeconfig.yaml' -o -name 'kcp.admin-token' | xargs -rt rm
