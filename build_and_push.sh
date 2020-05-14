#!/usr/bin/env sh
#shellcheck shell=sh

REPO=mikenye
IMAGE=picard

# Build
docker image rm ${REPO}/${IMAGE}:builder
docker image rm jlesage/baseimage-gui:ubuntu-18.04
docker build --no-cache -f Dockerfile -t ${REPO}/${IMAGE}:builder .

# Get version
VERSION=$(docker run --rm --entrypoint picard ${REPO}/${IMAGE}:builder -V | tail -1 | tr -s " " | cut -d " " -f 2 | tr -d ",")

docker tag ${REPO}/${IMAGE}:builder ${REPO}/${IMAGE}:${VERSION}
docker tag ${REPO}/${IMAGE}:builder ${REPO}/${IMAGE}:latest

docker push ${REPO}/${IMAGE}:${VERSION}
docker push ${REPO}/${IMAGE}:latest
