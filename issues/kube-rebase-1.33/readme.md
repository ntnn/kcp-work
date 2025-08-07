# steps

loosely following

https://docs.kcp.io/kcp/v0.27/contributing/rebasing-kubernetes/

# update kcp-dev/apimachinery

## go.mod

update go version

update everything from k/k/staging to v0.33.2

    go get k8s.io/klog/v2@latest

    go get k8s.io/utils@latest

## check

    make lint test

# update kcp-dev/code-generator

## go.mod

update everything from k/k/staging to v0.33.2

    go get k8s.io/code-generator@v0.33.3

    go get k8s.io/klog/v2@latest

## examples/go.mod

update everything from k/k/staging to v0.33.2

    go get k8s.io/apimachinery@v0.33.3
    go get k8s.io/client-go@v0.33.3

TODO: update kcp-dev/apimachinery

TODO: update kcp-dev/client-go

## check

    make codegen

    git add .
    git commit -m codegen

commit

    make lint test

# update kcp-dev/client-go

## go.mod

update go.version

update everything from k/k/staging to v0.33.2

    go get k8s.io/klog/v2@latest

TODO: update kcp-dev/apimachinery
TODO: update kcp-dev/code-generator

## check

    make codegen

    git add .
    git commit -m codegen

    ./hack/populate-copies.sh

Check and update each file to preserve the cluster-awareness and rename
types as needed. Also check for entirely new functions and methods that
need to be made cluster-aware.

    TODO: in listers/.../._expaniong.o - separate the `...Cluster...Expansion` types into _kcp files? would remove them from future diffs

    make lint

# update kcp-dev/kubernetes

oh boy!

This assumes that k/k is added as a remote as kubernetes and kcp-dev/k
is as the remote kcp-dev.

## get the commits

    git reset kcp-dev/kcp-1.32.3

export the commits on the current kcp-dev/kubernetes fork until the last
k/k release:

    git log --oneline --reverse --no-merges --no-decorate v1.32.3..HEAD \
        | grep -v '<drop>' > commits.txt

We will use this list to cherry-pick each commit one by one.

Then reset to the last k/k release:

    git reset --hard v1.33.3

## prep k/k

## cherry-picking

Check every `UPSTREAM: <number>:` whether the PR was merged. If so it
can be omitted. Everything else needs to be cherry-picked.

!CAUTION: Also check if a PR was reverted.

Then go through the list of commits one by one and cherry-pick them.

It is a good idea to run at least the linter after each one to find
potential issues early.

    git diff --name-only v1.32.3 v1.33.3 > ../changed_files.txt

    list_changed_files() {
        for changed_file in $(git diff --name-only @ @~1); do
            if grep -q "$changed_file" ../changed_files.txt; then
                echo "./$changed_file"
            fi
        done
    }

    view_changed_files() {
        local changed="$(list_changed_files)"
        [[ -z "$changed" ]] && return 0
        git diff-tree -r -p @  -- $changed
    }

    diff_changed_files() {
        git diff-tree -r -p @  -- "$(list_changed_files)"
    }

    changed_pkgs() {
        git diff --name-only kubernetes/release-1.32 kubernetes/release-1.33  \
            | grep -v -e go.mod -e go.sum -e hack -e LICENSES \
            | xargs dirname \
            | grep -v '^vendor' \
            | grep -v '^.$' \
            | grep -v '^staging/src/k8s.io/cri-client$' \
            | sort | uniq | xargs printf './%s\n'
    }

    changed_pkgs

    go vet $(changed_pkgs)

    CGO_ENABLED=1 make lint WHAT="$(changed_pkgs)"

    CGO_ENABLED=1 make test WHAT="$(changed_pkgs)"

### Prepping kcp-dev deps

Cherry-pick the commit that allows pin-dependencies to point to a local
directory.

    g cherry-pick 0c9556fe4ac5dfccc4698978ce5b3be366f2c920

Then add the kcp dependencies - you will need them to validate the
changes down the line. In the preparation phase you can use whatever is
main and use a go workspace to point to your local fork and then update
again later when the deps are updated.

    hack/pin-dependency.sh github.com/kcp-dev/logicalcluster/v3 latest

    hack/pin-dependency.sh github.com/kcp-dev/apimachinery/v2=/Users/I567861/SAPDevelop/code/kcp-work/kcp-apimachinery main

    hack/pin-dependency.sh github.com/kcp-dev/client-go=/Users/I567861/SAPDevelop/code/kcp-work/kcp-client-go main

    hack/pin-dependency.sh github.com/kcp-dev/apimachinery/v2 kcp-1.33.3
    hack/pin-dependency.sh github.com/kcp-dev/client-go kcp-1.33.3

    git add .
    git commit -m 'CARRY: <drop>: Add KCP dependencies'

We'll do this again later but once the PRs are merged upstream.

These changes will be dropped later - we just need the kcp deps
available when cherry-picking the carry commits and testing them.

And update the go.mod files and vendor directories:

    hack/update-vendor.sh

    git add .
    git commit -m 'CARRY: <drop>: vendor'

## finalizing

And finally regenerate the client code:

    hack/update-codegen.sh

This can update the kube dependencies to a version instead of keeping it
at v0.0.0. That will break scripts further down the line, so that needs
to be fixed:

    gsed -e '/k8s.io/ s#v0.33.3#v0.0.0#' -i "go.mod"
    find staging -iname go.mod \
        | while read go_mod; do
            gsed -e '/k8s.io/ s#v0.33.3#v0.0.0#' -i "$go_mod"
        done


TODO this deletes `zz_generated.validations.go` in
`staging/src/k8s.io/code-generator/cmd/validation-gen/output_tests/tags/`

    git add .
    git commit -m 'CARRY: <drop>: codegen'

# update kcp

update the deps

    g cherry-pick b7c7cdff59bc7afe385df217d06e0b767e7a1113 # go version fixup

    g cherry-pick 4b092653158a31e97a299d76a71f72f9194fe51d # DefaultKubeEffective
    g cherry-pick ab4abcc905ebce664972e857d16c9e38a3c97a40 # fixup

    g cherry-pick 80a19e12cbe57606b7937efb202edf023196f429 # random assortment

    g cherry-pick 0dcd5719f # ignore error instead of errcheck

    go mod edit -replace k8s.io/kubernetes=../kubernetes
    find ../kubernetes/staging/src/k8s.io -mindepth 1 -maxdepth 1 | while read staging; do
        go mod edit -replace "k8s.io/${staging##*/}=$staging"
    done

    cd sdk
    go mod edit -replace k8s.io/kubernetes=../../kubernetes
    find ../../kubernetes/staging/src/k8s.io -mindepth 1 -maxdepth 1 | while read staging; do
        go mod edit -replace "k8s.io/${staging##*/}=$staging"
    done

Compare go.mod dependencies between the various go.mods and kube
dependencies:

    ./hack/verify-go-modules.sh

And between the different components:

    TODO


Update to kcp-dev/kubernetes kcp-1.33.3

    BRANCH=kcp-1.33.3 ./hack/bump-k8s.sh

run codegen

    CGO_LDFLAGS="-w" make codegen

    CGO_LDFLAGS="-w" mymake lint

    CGO_LDFLAGS="-w" mymake test

    CGO_LDFLAGS="-w" mymake test-integration

    CGO_LDFLAGS="-w" mymake test-e2e

    CGO_LDFLAGS="-w" mymake test-e2e-shared-minimal

    CGO_LDFLAGS="-w" mymake test-e2e-sharded-minimal

# notes

even the added tests from kcp in kube are failing

rbac policy hook is started two times?
