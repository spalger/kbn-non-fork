#!/usr/bin/env bash

for task in "$@"
do
    "/repo/$task"
done
