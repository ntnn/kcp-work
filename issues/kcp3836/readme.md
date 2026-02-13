# cross workspace authz webhook payloads

## setup

start webhookauth

    cd kube-authz-webhook-debug && go run ./cmd/webhook

start kcp with webhookauth

    ./hacks/kcp-raw webhookauth

create test setup

    ./hacks/create-ws root:provider

    ./hacks/create-ws root:consumer

create apiexport

    k --context root:provider apply -f https://raw.githubusercontent.com/kcp-dev/kcp/refs/heads/main/test/e2e/virtual/apiexport/crd_cowboys.yaml

    k --context root:provider get crd cowboys.wildwest.dev -o yaml \
        | k kcp crd snapshot -f- --prefix today \
        | k --context root:provider apply -f-

    k --context root:provider apply -f ./issues/kcp3513/apiexport.yaml

    k --context root:provider create clusterrolebinding provider-all-authenticated \
        --clusterrole=apiexport-editor \
        --group=system:authenticated

bind apiexport in consumer with service account

    k --context root:consumer create serviceaccount apibinder

allow service account to create apibindings in consumer

    k --context root:consumer create clusterrole apibinding-editor \
        --verb=create,update,patch,delete,get \
        --resource=apibindings

    k --context root:consumer create clusterrolebinding apibinder \
        --clusterrole=apibinding-editor \
        --serviceaccount=default:apibinder

bind apiexport in consumer

    token=$(k --context root:consumer create token apibinder --duration=24h)

    k kcp bind apiexport root:provider:cowboys.wildwest.dev \
        --name cowboys.wildwest.dev \
        --context root:consumer \
        --token "$token"

    k --context root:consumer delete apibinding cowboys.wildwest.dev
