#!/usr/bin/env bash

set -e

# tell git who we are
git config --global user.email "kibana-ci@ci.container"
git config --global user.name "Kibana CI"

# workaround for scripts that expect this to be a real repo
git init
git commit --quiet --allow-empty -m 'commit so we have a usable repo'

# ensure that all dependencies are up to date, respecing semver
npm --depth 9999 update
