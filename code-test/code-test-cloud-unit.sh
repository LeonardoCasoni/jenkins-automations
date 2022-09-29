#!/bin/bash -u

if [ "$UNIT" = true ]; then
    echo "DEVOPS Check: UNIT tests started with npm"
    npm run test --workspaces > ../../volume/logs/unit.log
    echo "DEVOPS Check: UNIT tests done"
fi
