
    resettmp() {
        basedir=$(mktemp -d)
        mkdir -p "$basedir"/{artifacts,work,logs}
        export ARTIFACT_DIR="$basedir/artifacts"
        export WORK_DIR="$basedir/work"
        export LOG_DIR="$basedir/logs"
        echo "$basedir"
    }

    make -C kcp-code-generator codegen

    make -C kcp-code-generator codegen && make -C kcp-client-go codegen && make -C kcp codegen

    make -C kcp-apimachinery test

    make -C kcp-code-generator lint test

    make -C kcp-client-go lint

    resettmp && make -C kcp test

    resettmp && make -C kcp test-integration

    resettmp && make -C kcp test-e2e

    resettmp && make -C kcp test-e2e-shared-minimal

    resettmp && make -C kcp test-e2e-sharded-minimal

    make -C kcp-apimachinery test && make -C kcp-code-generator test && make -C kcp test test-integration test-e2e test-e2e-shared-minimal test-e2e-sharded-minimal


rm -rf .kcp ; go run ./kcp/cmd/kcp start

k apply -f ../quota.yaml

k delete -f ../quota.yaml
