#!/usr/bin/env bash
#shellcheck shell=bash

REPO=mikenye
IMAGE=picard

# Build latest
docker image rm jlesage/baseimage-gui:ubuntu-18.04
docker buildx build --no-cache -f Dockerfile --push -t "${REPO}/${IMAGE}:latest" .

# Get version
docker pull "${REPO}/${IMAGE}:latest"
VERSION=$(docker run --rm --entrypoint picard "${REPO}/${IMAGE}:latest" -V | tail -1 | tr -s " " | cut -d " " -f 2 | tr -d ",")

# Build version specific
docker buildx build --no-cache -f Dockerfile --push -t "${REPO}/${IMAGE}:${VERSION}" .
