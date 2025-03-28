# deploying api-syncagent

## prep

```bash
syncsource="$(pwd)/kind-syncsource.kubeconfig"
../hacks/kind.sh syncsource default "$syncsource"
```

```bash
synctarget_raw="$(pwd)/kind-synctarget.kubeconfig"
../hacks/kind.sh synctarget kcp "$synctarget_raw"
```

```bash
syncer="$(pwd)/kind-syncer.kubeconfig"
../hacks/kind.sh syncer default "$syncer"
```

```bash
# install kcp in synctarget
synctarget="$(pwd)/kcp-synctarget.kubeconfig"
../hacks/kcp.sh "$synctarget_raw" "$synctarget"
```

## prepare synctarget

```bash
export KUBECONFIG="$synctarget"
```

create a workspace
```bash
k create-workspace a --ignore-existing
k ws :root:a
```

create an empty apiexport in the workspace
```bash
k apply -f apiexport.yaml
k get apiexport
```

add rbac for the syncagent
```bash
k apply -f api-syncagent-rbac.yaml
```

## install syncagent

```bash
export KUBECONFIG="$syncsource"
k create ns kcp-system
```

Create kubeconfig for target system to use in syncagent.
The kubeconfig needs to be updated to point to the synctarget control
plane. Luckily kind places all clusters in the same bridge network, so
there's no need for network magic.

This codeblock doesn't work as there are multiple clusters/workspaces
listed in the kubeconfig.
```bash
bridge_address="$(yq -r '.clusters[0].cluster.server' "$synctarget" | sed 's#127.0.0.1#synctarget-control-plane#')" \
    yq ".clusters[0].cluster.server = env(bridge_address)" "$synctarget" > "$synctarget.tmp"
```

```bash
sed -e 's#127.0.0.1#synctarget-control-plane#g' "$synctarget" > "$synctarget.tmp"

k create secret generic kcp-kubeconfig --namespace kcp-system --from-file "kubeconfig=$synctarget.tmp"
```

Deploy syncagent with helm
```bash
helm upgrade --install kcp-api-syncagent kcp-dev/api-syncagent \
    --values ./api-syncagent.yaml \
    --namespace kcp-system \
    --wait

k -n kcp-system get pods
```

## Publishing a resources

As an example certmanager resources will be published, so this needs to
be available in the source cluster.

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

And deploy the published resource in the kcp-system namespace
```bash
k apply -n kcp-system -f published-resources.yaml
```
