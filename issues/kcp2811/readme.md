<https://github.com/kcp-dev/kcp/issues/2811>

    kset .kcp/admin.kubeconfig

    k ws tree

    k apply -f ./issues/kcp2811/resources.yaml

    token="$(yq '.users[0].user.token' .kcp/admin.kubeconfig)"

    curl -v -k -H "Authorization: Bearer $token"  https://127.0.0.1:6443/clusters/root/apis/wildwest.dev/v1alpha1/namespaces/default/clusters/woody/status

    curl -v -k -H "Authorization: Bearer $token"  https://127.0.0.1:6443/clusters/root/clusters/root/clusters/root/apis/wildwest.dev/v1alpha1/namespaces/default/clusters/woody/status

    curl -k -H "Authorization: Bearer $token"  https://127.0.0.1:6443/clusters/root/clusters/root/apis/wildwest.dev/v1alpha1/namespaces/default/clusters/woody/status

    curl -k -H "Authorization: Bearer $token"  https://127.0.0.1:6443/clusters/roota/clusters/root/apis/wildwest.dev/v1alpha1/namespaces/default/clusters/woody/status

    curl -k -H "Authorization: Bearer $token"  https://127.0.0.1:6443/clusters/root/clusters/rootb/apis/wildwest.dev/v1alpha1/namespaces/default/clusters/woody/status

    curl -k -H "Authorization: Bearer $token"  $(k get logicalclusters.core.kcp.io cluster -o jsonpath='{.status.URL}')/apis/core.kcp.io/v1alpha1/logicalclusters/cluster/status

    k apply -f ./issues/kcp2811/clusterCrd.yaml

    k apply -f ./issues/kcp2811/cluster.yaml

    token="$(yq '.users[0].user.token' .kcp/admin.kubeconfig)"

    curl -v -k -H "Authorization: Bearer $token"  https://127.0.0.1:6443/clusters/root/apis/url.test/v1/clusters/woody

    curl -v -k -H "Authorization: Bearer $token"  https://127.0.0.1:6443/clusters/root/apis/url.test/v1/clusters/woody/status
