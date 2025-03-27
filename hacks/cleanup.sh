#!/usr/bin/env sh

kind delete clusters $(kind get clusters)

(
    cd "$(dirname "$0")/.."
    git clean -fdX
)
