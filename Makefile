all: build

build:
	graphite/build.sh

push: build
	graphite/push.sh

.PHONY: all
