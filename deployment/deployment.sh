#!/bin/bash -u

echo "DEVOPS Check: Checking variables and configurations"

# use jenkins git private key
mv -f "$SSH_KEY_LOCATION" ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

cd deployer || exit 1
rm -rf __workspace
rm -rf __manifests
rm -f deploymentConfig.json

#Setting the generic values and configurations
if [ "$SPACE" = "next" ] || [ "$SPACE" = "staging" ] || [ "$SPACE" = "production" ]; then
    MANIFEST_NAME="deployment-$ORG-cloud-$SPACE-$VERSION"
else
    MANIFEST_NAME="deployment-$ORG-cloud-$SPACE"
fi

#For safety reason, I will set to false all the options for the staging and production environments
if [ "$SPACE" = "staging" ] || [ "$SPACE" = "production" ]; then
    if [ "$CONFIRM" = false ]; then echo "You did not select the CONFIRM option, so I have to exit"; exit 1; fi;
    CLEANUP=false
    DELETE_DATA=false
    CLEANER=false
fi

#I will wait 30 minute only if the test environemtn and the WAIT options are selected together
if [[ "${SPACE}" = "test" && "${WAIT}" = true ]]; then echo "Wait 30 minutes to start the deployment" && sleep 30m; fi

#Setting the specific variables and configurations based on the ORG and SPACE selected
if [ "$ORG" = "cloud" ]; then
    GROUP=("$ORG-$SPACE-json" "app1_private_key" "app1_cert" "app2_private_key" "app2_public_cert" \
        "app3_intermediate_cert" "app4_root_cert")

    if [ "$SPACE" = "staging" ] || [ "$SPACE" = "production" ]; then
        if [ "$CONFIRM" = false ]; then echo "You did not select the CONFIRM option, so I have to exit"; exit 1; fi;
        REBUILD=false
    fi

    Deployment() {
        if [ "$REBUILD" = true ]; then
            #here you can decide your deployment command
            echo "deployment rebuild"
        elif [ "$CLEANER" = true ]; then
            #here you can decide your deployment command
            echo "deployment cleaner"
        else
            #here you can decide your deployment command
            echo "deployment default"
        fi
    }

    elif [ "$ORG" = "iot" ]; then
    if [ "$SPACE" != "production" ]; then
    #here you can manage different secrets for non production environments
        GROUP=("$ORG-$SPACE-json" "app1_private_key" "app1_cert" "app2_private_key" "app2_public_cert")
    else
    #here you can manage different secrets for non production environments
        GROUP=("$ORG-$SPACE-json" "app1_private_key" "app1_cert" "app2_private_key" "app2_public_cert")
    fi

    Deployment() {
        if [ "$REBUILD" = true ]; then
            #here you can decide your deployment command
            echo "deployment rebuild"
        elif [ "$CLEANER" = true ]; then
            #here you can decide your deployment command
            echo "deployment cleaner"
        else
            #here you can decide your deployment command
            echo "deployment default"
        fi
    }

    else
    echo "ERR: $ORG not found!"
    exit 1
fi

echo "DEVOPS Check: NPM management"

#We will trigger a dedicated shell script for npm stuff
../../volume/npm_management.sh

#--- GET THE SECRETS AND PUT THEM INTO THE /secrets FOLDER ---#
echo "DEVOPS Check: Downloading Secrets"

rm -f ./*.temp
rm -rf secrets
mkdir -p secrets

for i in "${GROUP[@]}"; do
    # Defining the right secret name to for the next step
    if [ "$i" = "$ORG-$SPACE-json" ]; then
        NAME="$i"
    else
        NAME="$ORG-$SPACE-$i"
    fi

	# Write a temp file for each group + Cleanup content
    echo "Fetching $NAME from AWS SecretsManager"
	aws secretsmanager get-secret-value --query SecretString --secret-id \
    arn:aws:secretsmanager:eu-central-1:"$SECRETS_ACCOUNT":secret:"$NAME" > "$i".temp
    sed -i 's/\\n/\n/g' "$i".temp; sed -i 's/\\//g' "$i".temp
    sed -i '$ s/.$//' "$i".temp; sed -i '1s/^.//' "$i".temp
    
    # Set file types for Json files
    if echo "$ORG-$SPACE-json" | grep -Fxq "$i"; then
	    mv -f "$i".temp secrets/"$ORG-$SPACE".json
    else 
    	mv -f "$i".temp secrets/"$i"
    fi
done

#--- CLEANUP TEMP ---#
rm -f ./*.temp

echo "DEVOPS Check: START Deployment process"

Deployment

if [ $? -eq 0 ]; then
    echo OK; RESULT="PASSED"
else
    echo FAIL; RESULT="FAILED"
fi

echo "DEVOPS Check: END of Deployment process"

#--- CLEANUP SECRETS ---#
rm -rf secrets/

if [ "$RESULT" = 'FAILED' ]; then
    exit 1
fi
