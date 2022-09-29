#!/usr/bin/env bash
NEW_VERSION="18.0.4"
new_release_file="release-${ORG}-cloud-${VERSION}.json"

echo "Checking if the release files exist"
if [ -f "release/$new_release_file" ]; then
    echo "The release is already created! I will not proceed"
    exit 1
    else
    echo "The release file do not exist, so I can proceed"
fi

latest_release_file=$(ls release/ | grep '[0-9]' | sort --version-sort | tail -1)
cp -apu release/"$latest_release_file" release/"$new_release_file"
sed -i "s+\"version\": $PARTITION_COLUMN.*+\"version\": \"${VERSION}\",+g" release/"$new_release_file"
sed -i "s+\"referenceValue\": \"v$PARTITION_COLUMN.*+\"referenceValue\": \"v${VERSION}\"+g" release/"$new_release_file"

echo "Creating the new release manifests"
for dep in next staging production
do
    latest_manifest=$(ls deployment/ | grep "$dep" | grep '[0-9]' | sort --version-sort | tail -1)
    new_manifest="deployment-${ORG}-cloud-$dep-${VERSION}.json"
    cp -apu deployment/"$latest_manifest" deployment/"$new_manifest" 
    sed -i "s+amazonaws.com/production:$PARTITION_COLUMN.*+amazonaws.com/production:${VERSION}\"+g" deployment/"$new_manifest"
    sed -i "s+\"manifest\": \"$PARTITION_COLUMN.*+\"manifest\": \"${new_release_file}\"+g" deployment/"$new_manifest"
done
