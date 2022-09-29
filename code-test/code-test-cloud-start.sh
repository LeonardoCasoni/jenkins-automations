#!/bin/bash -u
#Example of a preparation for integration tests

if [ "$INTEGRATION" = true ]; then
    echo 'DEVOPS Check: Docker compose up sequence'
    cd development || exit 1
    docker volume prune --force  # we start with empty DBs
    docker-compose up -d --force-recreate
    sleep 120
    docker-compose ps
    cd - || exit 1
    echo 'DEVOPS Check: Starting cloud'
    npm start
    echo 'DEVOPS Check: cloud started'
fi