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

## install syncagent

```bash
export KUBECONFIG="$syncsource"
k create ns kcp-system
```

Create kubeconfig for target system to use in syncagent
```bash
k create secret generic kcp-kubeconfig --namespace kcp-system --from-file "kubeconfig=$synctarget"
```

Deploy syncagent with helm
```bash
helm upgrade --install kcp-api-syncagent kcp-dev/api-syncagent \
    --values ./api-syncagent.yaml \
    --namespace kcp-system \
    --wait

k -n kcp-system get pods
```

