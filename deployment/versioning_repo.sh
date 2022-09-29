#!/usr/bin/env bash
NEW_VERSION="18.0.4"
HOMEDIR=$(pwd)

echo "Checking if the versioning folder exist"
if [ -d "versioning/v${VERSION}" ]; then
    echo "The directory versioning/v${VERSION} exist, so I can proceed with versioning"
    else
    echo "The directory versioning/v${VERSION} DO NOT exist, so I cannot proceed with versioning"
    exit 1
fi
sed -i "s+versioning/v$PARTITION_COLUMN.*+versioning/v${VERSION}/';+g" utilities/infrastructure/"${ORG}"-versioning/index.js
cd utilities/infrastructure/"${ORG}"-versioning || exit 1
npm install
npm start
cd "$HOMEDIR" || exit 1
sed -i "s+\"version\": $PARTITION_COLUMN.*+\"version\": \"${VERSION}\",+g" package.json
