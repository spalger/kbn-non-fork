#!/usr/bin/env bash

for task in "$@"
do
    "/repo/ci/tasks/$task"
done
