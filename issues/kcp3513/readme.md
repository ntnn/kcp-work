See https://github.com/kcp-dev/kcp/issues/3513

# Allow any authenticated user to bind

## Setup

    kset .kcp/admin.kubeconfig

    k ws tree

    ./hacks/create-ws ":root:provider"

    ./hacks/create-ws ":root:consumer"

    k ws tree

## Create APIExport in provider

    k --context root:provider apply -f https://raw.githubusercontent.com/kcp-dev/kcp/refs/heads/main/test/e2e/virtual/apiexport/crd_cowboys.yaml

    k --context root:provider get crd cowboys.wildwest.dev -o yaml \
        | k kcp crd snapshot -f- --prefix today \
        | k --context root:provider apply -f-

    k --context root:provider apply -f ./issues/kcp3513/apiexport.yaml

To let all authenticated users bind:

    k --context root:provider apply -f ./issues/kcp3513/provider-all-authenticated.yaml

To only let users from the consumer workspace bind:

    consumer_cluster_id=$(k get ws consumer -o jsonpath='{.spec.cluster}')

    yq '.subjects[0].name = "system:cluster:'$consumer_cluster_id'"' \
        ./issues/kcp3513/provider-only-consumer-ws.yaml \
        | k --context root:provider apply -f -

## Bind APIExport in consumer

    k --context root:consumer apply -f ./issues/kcp3513/consumer.yaml

    token=$(k --context root:consumer create token apibinder --duration=24h)

    k ws :root:consumer

    k kcp workspace create-context consumer-apibinder \
        --token "$token" \
        --overwrite
    k config use-context workspace.kcp.io/current

    # TODO seems create-context is bugged
    k config set-credentials apibinder --token "$token"
    k config set-context consumer-apibinder --user apibinder

    # TODO create-context always switches to the new context
    k ws :root

    k --context consumer-apibinder auth whoami

    k kcp bind apiexport root:provider:cowboys.wildwest.dev \
        --name cowboys.wildwest.dev \
        --context consumer-apibinder

    k --context consumer-apibinder apply -f ./issues/kcp3513/apibinding.yaml

    k --context root:consumer get cowboys.wildwest.dev
