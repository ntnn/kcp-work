<https://github.com/kcp-dev/kcp/issues/2811>

    kset .kcp/admin.kubeconfig

    k ws tree

    k apply -f ./issues/kcp2811/resources.yaml

    k create configmap test --from-literal a=b

    token="$(yq '.users[0].user.token' .kcp/admin.kubeconfig)"

    curl -k -H "Authorization: Bearer $token"  https://127.0.0.1:6443/clusters/root/apis/wildwest.dev/v1alpha1/namespaces/default/clusters/woody/status

# normal status request

    kind create cluster

    k create serviceaccount testsa

    k create clusterrolebinding testsa --clusterrole=cluster-admin --serviceaccount=default:testsa

    token="$(k create token testsa)"

    baseurl="$(yq '.clusters[0].cluster.server' ~/.kube/config)"

    k create deployment testdeploy --image=nginx

    curl -k -H "Authorization: Bearer $token"  "$baseurl/apis/apps/v1/namespaces/default/deployments/testdeploy/status"
