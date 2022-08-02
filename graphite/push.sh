#!/bin/bash
set -eufo pipefail

command -v docker >/dev/null 2>&1 || { echo "docker is not installed"; exit 1; }

docker push us.gcr.io/kubernetes-dev/graphite-mt:$(cat .docker_tag)

docker tag us.gcr.io/kubernetes-dev/graphite-mt:$(cat .docker_tag) us.gcr.io/kubernetes-dev/graphite-mt:latest
docker push us.gcr.io/kubernetes-dev/graphite-mt:latest
