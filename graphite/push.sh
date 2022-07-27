#!/bin/bash
set -x

docker push us.gcr.io/kubernetes-dev/graphite-mt:$(cat .docker_tag)

docker tag us.gcr.io/kubernetes-dev/graphite-mt:$(cat .docker_tag) us.gcr.io/kubernetes-dev/graphite-mt:latest
docker push us.gcr.io/kubernetes-dev/graphite-mt:latest
