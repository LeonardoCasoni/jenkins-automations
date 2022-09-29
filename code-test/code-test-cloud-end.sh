#!/bin/bash -u
#Example of shutting down all the tools for the integration tests

if [ "$INTEGRATION" = true ]; then
    echo "DEVOPS Check: Docker compose down sequence"
    grunt server:stop
    cd development && docker-compose down || true

    [ ! -e ${WORKSPACE_TMP}/FAILED ]
fi
