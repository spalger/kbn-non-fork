#!/usr/bin/env bash

set -e

# we date our cache so that it is always rebuilt from scratch once a week
date="$(date +%Y_%W)"
cache_dir=~/docker-cache
cache_name="images_$date.tar"
images_tar="$cache_dir/$cache_name"

if [[ -d "$cache_dir" ]]; then
  # clear out unneeded caches
  for cache in "$(find $cache_dir -maxdepth 1 -name '*.tar' -not -name $cache_name)"; do
    rm -rfv "$cache"
  done
fi

if [[ -f "$images_tar" ]]; then
  docker load < "$images_tar";
fi

build_tag="kibana-ci/task-runner:$CIRCLE_SHA1"
docker build -t "$build_tag" --file ci/Dockerfile .

# also save the upstream box, or the cache doesn't work
docker save "$build_tag" buildpack-deps:xenial > "$images_tar"
