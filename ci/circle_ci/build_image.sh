#!/usr/bin/env bash

set -e

# we date our cache so that it is always rebuilt from scratch once a week
date="$(date +%Y_%W)"
cache_dir=~/docker-cache

base_cache_name="base_image.tar"
base_cache_path="$cache_dir/$base_cache_name"
base_tag="kibana-ci/base:$CIRCLE_BRANCH"

runner_cache_prefix="runner_image_"
runner_cache_name="${runner_cache_prefix}${date}.tar"
runner_cache_path="$cache_dir/$runner_cache_name"
runner_tag="kibana-ci/task-runner:$CIRCLE_SHA1"

# ensure the cache directory exists
mkdir -p $cache_dir

# load of remove cache items
caches="$(find $cache_dir -maxdepth 1 -name '*.tar')"
for c in $caches; do
  if [ "$c" == "$base_cache_path" ] || [ "$c" == "$runner_cache_path" ] ; then
    docker load < "$c";
  else
    echo "removing outdated cache item $c";
    rm -rfv "$c";
  fi
done

# build the base image
docker build -t "$base_tag" --file ci/base/Dockerfile .
# save the base image and it's upstream to cache
docker save "$base_tag" buildpack-deps:xenial > "$base_cache_path"

# build the runner image
docker build -t "$runner_tag" --file ci/task_runner/Dockerfile .
# save the runner image to cache
docker save "$runner_tag" > "$runner_cache_path"
