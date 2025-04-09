# deploying KCP in kind

## setup

syncsource has cert-manager and KRO
synctarget has KCP

```bash
syncsource="$(pwd)/kind-syncsource.kubeconfig"
../../hacks/kind.sh syncsource default "$syncsource"
```

```bash
synctarget_raw="$(pwd)/kind-synctarget.kubeconfig"
../../hacks/kind.sh synctarget kcp "$synctarget_raw"
```

```bash
synctarget="$(pwd)/kcp-synctarget.kubeconfig"
../../hacks/kcp.sh "$synctarget_raw" "$synctarget"
```

## setup PKI in syncsource

install cert-manager

```bash
export KUBECONFIG="$syncsource"
kubectl apply -n cert-manager \
    -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.crds.yaml
helm upgrade \
  --install \
  --wait \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  cert-manager jetstack/cert-manager
```

create a self-signed cluster issues

```bash
export KUBECONFIG="$syncsource"
k apply -f pki/cert-manager-pki.yaml
```

create a test certificate

```bash
export KUBECONFIG="$syncsource"
k create ns test-certificate
k apply -f pki/test-certificate.yaml
```

check the certificate

```bash
export KUBECONFIG="$syncsource"
k -n test-certificate get secret test-certificate -o yaml
```

## setup KRO

install kro

```bash
export KUBECONFIG="$syncsource"
k apply -f https://raw.githubusercontent.com/kro-run/kro/refs/tags/v0.2.2/config/crd/bases/kro.run_resourcegraphdefinitions.yaml
helm upgrade \
  --install \
  --wait \
  --namespace kro \
  --create-namespace \
  --version 0.2.2 \
  kro oci://ghcr.io/kro-run/kro/kro
```

deploy the resource graph definition to wrap around the cert-manager
certificate

```bash
export KUBECONFIG="$syncsource"
k create ns kro-pki
k apply -f pki/kro-pki.yaml
```

```bash
export KUBECONFIG="$syncsource"
k create ns test-certificate-kro
k apply -f pki/test-certificate-kro.yaml
```

and admire the resulsting certificate:

```bash
export KUBECONFIG="$syncsource"
k -n test-certificate-kro get secret test-kro -o yaml
```

#
