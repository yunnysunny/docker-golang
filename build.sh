#!/bin/bash
set -e

export GO_VERSION=1.18
TAG_LATEST=yunnysunny/golang:latest
TAG_CURRENT=yunnysunny/golang:${GO_VERSION}

docker pull golang:${GO_VERSION}
docker build . -f ./Dockerfile -t ${TAG_LATEST} -t ${TAG_CURRENT} --build-arg GO_VERSION=${GO_VERSION}
if [ "$NEED_PUSH" = "1" ] ; then
    docker push ${TAG_LATEST}
    docker push ${TAG_CURRENT}
fi