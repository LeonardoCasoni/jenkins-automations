#!/bin/bash -u
HOMEDIR=$(pwd)

Naming() {
    APPNAME=$(echo "$thisapp" | sed +s+services/++ | sed +s+/+-+)
    IMAGE=$PRODUCT-$APPNAME
}

DockerTagging() {
    #I will use the BRANCH name for the develop test (qa) and review environments and the VERSION for the Next, Staging and Production environments
    if [ "$SPACE" = "develop" ] || [ "$SPACE" = "qa" ]; then
        NEWTAG=$BRANCH
    else
        NEWTAG=$(cat services/"$thisapp"/package.json | jq -r ".version" | sed +s+\",++ | sed +s+\"++)
    fi

    #Starting to build the images with the right naming and tagging
    docker tag "$IMAGE":latest "$ACCOUNT"/"$IMAGE":"$NEWTAG"
    docker push "$ACCOUNT"/"$IMAGE":"$NEWTAG"
    docker images
    docker image rm -f "$IMAGE" "$ACCOUNT"/"$IMAGE":"$NEWTAG"
    docker images
}

#Logging in to the AWS account with Docker
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin "$ACCOUNT"

if [ "$SERVICE" = "all" ]; then
    LISTFOR=$(cat package.json | jq -r ".workspaces" | grep "services/" | sed +s+\\",++ | sed +s+\\"++)
    DockerBuilding() {
        docker build -t "$IMAGE" --file docker/Dockerfile --build-arg NPM_TOKEN=${NPM_TOKEN} --build-arg WORKSPACE="$thisapp" .
    }
else
    LISTFOR=$SERVICE
    DockerBuilding() {
        docker build -t "$IMAGE" --file docker/Dockerfile --build-arg NPM_TOKEN=${NPM_TOKEN} --build-arg WORKSPACE=services/"$thisapp" .
    }
fi

for thisapp in $LISTFOR; do
Naming
DockerBuilding
DockerTagging
cd $HOMEDIR
done
