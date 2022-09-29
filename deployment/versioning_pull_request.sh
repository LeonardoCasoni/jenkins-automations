#!/usr/bin/env bash

if [ "$1" == "deployment" ]; then
    POSTFIX="cloud-deployment"
    else
    POSTFIX="cloud"
fi

curl https://bitbucket.company.com/rest/api/1.0/projects/porject/repos/"$ORG"-"$POSTFIX"/pull-requests \
    -u "$BITB_USER":"$BITB_PASSWORD" \
    --request POST \
    --header 'Content-Type: application/json' \
    --data '{
        "title": "'"$JIRA_ITEM_OK"' Versioning made by Jenkins",
        "description": "AUTOMATIC Versioning made by Jenkins",
        "state": "OPEN",
        "open": true,
        "closed": false,
        "fromRef": {
            "id": "release/v'"$VERSION"'"
        },
        "toRef": {
            "id": "'"$2"'"
        }
    }'