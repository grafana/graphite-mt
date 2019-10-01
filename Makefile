# VERSION is using this naming scheme: <our version>-<graphite version>
#
# our version:      a number to identify the graphite-mt image, it should be increased
#                   every time anything in this repo gets modified
# graphite version: the version of graphite that's used. preferrably the tag if there is one,
#                   otherwise the commit hash
#
VERSION=1-ge4ccaa21
PROJECT=raintank
APP=graphite-mt
TAG_LATEST=0

all: build

clean:
	docker run --rm -v $(shell pwd)/:/opt/graphite ubuntu:xenial rm -rf /opt/graphite/build-graphite

build: build-graphite
	docker build -t ${PROJECT}/${APP}:${VERSION} .

build-graphite:
	docker run --rm -v $(shell pwd)/build-graphite:/opt/graphite -v $(shell pwd)/graphite:/opt/build -e VERSION=e4ccaa2104499bcc8a39a5479b57a4af898bf9a4 ubuntu:xenial /opt/build/build.sh

push: build
	docker push ${PROJECT}/${APP}:${VERSION}
ifeq ($(TAG_LATEST), 1)
	docker tag ${PROJECT}/${APP}:${VERSION} ${PROJECT}/${APP}:latest
	docker push ${PROJECT}/${APP}:latest
endif

.PHONY: all build push
