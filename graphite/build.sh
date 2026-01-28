#!/bin/bash
set -eufo pipefail

command -v docker >/dev/null 2>&1 || { echo "docker is not installed"; exit 1; }

graphite/docker-tag.sh
docker build --progress=plain --platform linux/amd64 -t us.gcr.io/kubernetes-dev/graphite-mt:$(cat .docker_tag) .
