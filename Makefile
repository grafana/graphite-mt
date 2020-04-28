IMAGE_VERSION=7
GRAPHITE_VERSION=6827cc5b2
VERSION=${IMAGE_VERSION}-${GRAPHITE_VERSION}
PROJECT=raintank
APP=graphite-mt
TAG_LATEST=0

all: build

clean:
	docker run --rm -v $(shell pwd)/:/opt/graphite ubuntu:xenial rm -rf /opt/graphite/build-graphite

build: build-graphite
	docker build -t ${PROJECT}/${APP}:${VERSION} .

build-graphite:
	docker run --rm -v $(shell pwd)/build-graphite:/opt/graphite -v $(shell pwd)/graphite:/opt/build -e VERSION=${GRAPHITE_VERSION} ubuntu:xenial /opt/build/build.sh

push: build
	docker push ${PROJECT}/${APP}:${VERSION}
ifeq ($(TAG_LATEST), 1)
	docker tag ${PROJECT}/${APP}:${VERSION} ${PROJECT}/${APP}:latest
	docker push ${PROJECT}/${APP}:latest
endif

.PHONY: all build push
