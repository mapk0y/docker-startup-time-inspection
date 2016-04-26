#!/bin/bash

set -e
set -u

make hello_world

time ./hello_world

for target in \
    cmd_bracket \
    cmd_double_quotation \
    entrypoint_bracket \
    entrypoint_double_quotation;
do
    # docker build
    docker build --pull -t img_${target} -f Dockerfile.${target} ./

    echo "### ${target} ###"
    for c in {1..5}; do
        # remove container if exist.
        docker ps --quiet --all --filter name=${target} | xargs -r docker rm

        docker run --name=${target} img_${target}
        end_time=$(date -d $(docker inspect -f {{.State.FinishedAt}} ${target}) +%s.%N)
        start_time=$(date -d $(docker inspect -f {{.State.StartedAt}} ${target}) +%s.%N)
        echo "${end_time} - ${start_time}" | bc
    done
done
