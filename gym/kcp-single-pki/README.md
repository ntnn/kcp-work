# deploying KCP in kind

## setup

deploy a kind cluster for kcp

```bash
kcp_raw="$(pwd)/kind.kubeconfig"
../../hacks/kind.sh kcp kcp "$kcp_raw"
```

install kcp in cluster

```bash
kcp="$(pwd)/kcp.kubeconfig"
../../hacks/kcp.sh "$kcp_raw" "$kcp"
```

## setup PKI team

PKI team offers certificates through APIExports. In this example the PKI
is just a rebranded cert-manager. In real world usecases this could be
a custom controller that calls to an external CA.

First create the workspace for the PKI team

```bash
k ws :root
k create-workspace pki
```

```bash
k ws :root:pki
k apply -f ./pki/APIResourceSchemas.yaml
k apply -f ./pki/APIExports.yaml
k apply -f ./pki/APIExportEndpointSlice.yaml
k apply -f ./pki/rbac.yaml
```

## setup whoami team

Create a workspace for the whoami team

```bash
k ws :root
k create-workspace whoami
```

The whoami team offers the wildly popular whoami service. To scale their
service they are migrating from VMs to a KCP workspace. In this move
they also want to get certificates from the PKI team automatically.

The first step is to create an APIBinding to have access to the resource
of the PKI team.

```bash
k ws :root:whoami
k apply -f ./whoami/APIBinding.yaml
```

View the bound APIs:

```bash
k api-resources --api-group='pki.massive.corp'
```

Create a certificate resource:
```bash
k apply -f ./whoami/certificate.yaml
```

## realizing pki

TODO: something actually creating resources

return to the pki workspace
```bash
k ws :root:pki
```

```bash
endpoint="$(k get apiexportendpointslices.apis.kcp.io pki.massive.corp -o yaml | yq '.status.endpoints[0].url')"

s="$endpoint/clusters/*"

k -s "$s" api-resources

k -s "$s" get certificates.pki.massive.corp -A

k -s "$s" get -A certificates -o custom-columns='WORKSPACE:.metadata.annotations.kcp\.io/cluster,NAME:.metadata.name'

k -s "$s" get -A certificates -o yaml

cluster_id="$(k -s "$s" get -A certificates -o yaml | yq '.items[0].metadata.annotations."kcp.io/cluster"')"

sc="$endpoint/$cluster_id"

k -s "$sc" api-resources

```

