#!/usr/bin/env bash

set -e

cache_dir=~/docker-cache

# npm dependencies might behave unexpectedly, so we include the year+week
# in the cache path to force a full rebuild once a week
date="$(date +%Y_%W)"
runner_cache_prefix="task_runner_"
runner_cache_name="${runner_cache_prefix}${date}.tar"
runner_tag="kibanaci/runner:latest"

# ensure the cache directory exists
mkdir -p $cache_dir

# load or remove cache items
echo " + checking for image caches"
cache_paths="$(find $cache_dir -maxdepth 1 -name '*.tar')"
for path in $cache_paths; do
  echo " ++ cache: $path"
  name="$(basename $path)"

  if [[ "$name" == "$runner_cache_name" ]]; then
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

echo " ++ runner image"
echo "  + building and tagging with '$runner_tag'"
docker build -t "$runner_tag" --file ci/Dockerfile .

echo "  + caching image at '$cache_dir/$runner_cache_name'"
docker save "$runner_tag" kibanaci/base:n447-j8-chrome > "$cache_dir/$runner_cache_name"
