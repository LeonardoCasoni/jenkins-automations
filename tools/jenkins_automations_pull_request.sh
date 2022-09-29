#!/usr/bin/env bash

curl https://bitbucket.company.com/rest/api/1.0/projects/project-name/repos/repo-name/pull-requests \
    -u "$BITB_USER":"$BITB_PASSWORD" \
    --request POST \
    --header 'Content-Type: application/json' \
    --data '{
        "title": "'"$JIRA_ITEM_OK"' PR made by Jenkins",
        "description": "AUTOMATIC PR made by Jenkins",
        "state": "OPEN",
        "open": true,
        "closed": false,
        "fromRef": {
            "id": "'"$B_FROM"'"
        },
        "toRef": {
            "id": "'"$B_TO"'"
        }
    }'
