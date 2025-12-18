# kcp3555

Start kcp with external etcd

    ./hacks/kcp-raw

Set kubeconfig

    kset .kcp/admin.kubeconfig

Apply owner configmap

    k apply -f ./issues/kcp3555/cm-owner.yaml

    owner_uid="$(k get configmaps cm-owner -o jsonpath='{.metadata.uid}')"

    yq ".metadata.ownerReferences[0].uid = \"$owner_uid\"" ./issues/kcp3555/cm-owned.yaml \
        | k apply -f-

    k get configmaps cm-owner -o yaml

    k get configmaps cm-owned -o yaml

    k delete configmaps cm-owner

## e2e test

    export ARTIFACT_DIR="$(pwd)/artifacts"

    make -C kcp test-e2e WHAT=./test/e2e/garbagecollector/ TEST_ARGS='-v -run=TestGarbageCollectorBuiltInCoreV1Types'

    rm -rf "$ARTIFACT_DIR" ; make -C kcp test-e2e WHAT=./test/e2e/garbagecollector/ TEST_ARGS='-v -run=TestGarbageCollectorVersionedCRDs'


    rm -rf "$ARTIFACT_DIR" ; make -C kcp test-e2e WHAT=./test/e2e/garbagecollector/

    rm -rf "$ARTIFACT_DIR" ; make -C kcp test-e2e
