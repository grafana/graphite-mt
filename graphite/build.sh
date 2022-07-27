#!/bin/bash
set -x

graphite/docker-tag.sh
docker build --platform linux/amd64 -t us.gcr.io/kubernetes-dev/graphite-mt:$(cat .docker_tag) .
