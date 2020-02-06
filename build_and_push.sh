#!/bin/sh

#VERSION=`picard -V | tr -s " " | cut -d " " -f 2 | tr -d ","`
#ARCH=`uname -m`
IMAGE=mikenye/picard

# Build
docker image rm ${IMAGE}:builder
docker image rm jlesage/baseimage-gui:ubuntu-18.04
docker build -f Dockerfile -t ${IMAGE}:builder .

# Get version
VERSION=`docker run --rm --entrypoint picard mikenye/picard:builder -V | tail -1 | tr -s " " | cut -d " " -f 2 | tr -d ","`

docker tag ${IMAGE}:builder ${IMAGE}:${VERSION}
docker tag ${IMAGE}:builder ${IMAGE}:latest

docker push ${IMAGE}:${VERSION}
docker push ${IMAGE}:latest

