#!/usr/bin/env bash

set -e

cache_dir=~/docker-cache

# the base image is super stable and docker's cache
# should be fine as long as it's valid
branch_sum="$(echo "$CIRCLE_BRANCH" | shasum | cut -d ' ' -f 1)"
base_cache_name="base_image_branch_${branch_sum}.tar"
base_tag="kibana-ci/base:branch_$branch_sum"
echo " + base - cache: $base_cache_name tag: $base_tag"

# unlike the base image, the runner image includes
# npm dependencies that might behave unexpectedly, so
# we include the year+week in the cache path to force a
# full rebuild once a week
date="$(date +%Y_%W)"
runner_cache_prefix="runner_image_${branch_sum}"
runner_cache_name="${runner_cache_prefix}_${date}.tar"
runner_tag="kibana-ci/task-runner:$CIRCLE_SHA1"
echo " + task_runner - cache: $runner_cache_name tag: $runner_tag"

# ensure the cache directory exists
mkdir -p $cache_dir

# load or remove cache items
echo " + checking image caches"
cache_paths="$(find $cache_dir -maxdepth 1 -name '*.tar')"
for path in $cache_paths; do
  echo " ++ cache: $path"
  name="$(basename $path)"

  if [[ "$name" == "$runner_cache_name" ]] || [[ "$name" != "$base_cache_name" ]]; then
    echo "  + loading cache into docker";
    docker load < "$path"
    continue;
  fi

  if [[ "$name" == $runner_cache_prefix* ]]; then
    echo "  + removing outdated runner cache";
    rm -rf "$path";
    continue;
  fi

  echo "  + ignoring irrelevant cache";
done

echo " ++ base image"
echo "  + building and tagging with '$base_tag'"
docker build -t "$base_tag" --file ci/base/Dockerfile .
echo "  + caching image at '$cache_dir/$base_cache_name'"
docker save "$base_tag" buildpack-deps:xenial > "$cache_dir/$base_cache_name"

echo " ++ runner image"
echo "  + building and tagging with '$runner_tag'"
docker build -t "$runner_tag" --file ci/task_runner/Dockerfile .

echo "  + caching image at '$cache_dir/$runner_cache_name'"
docker save "$runner_tag" > "$cache_dir/$runner_cache_name"
