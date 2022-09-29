#!/bin/bash -u
#This script will delete all the apps and services in CloudFoundry space
echo "DEVOPS Check: Checking variables"

#For safety reason, I will set to false all the options for the staging and production environments
if [ "$CONFIRM" = false ] || [ "$SPACE" = "staging" ] || [ "$SPACE" = "production" ]; then
    echo "You did not select the CONFIRM option, or you are trying to undeploy a blocked environmentm so I have to exit"
    exit 1
fi

APP=app.txt
#Get the name of the app to delete
cf a | grep -e 'cloud\|kafka' | awk '{print $1}' > "$APP"

DBS=dbs.txt
#Get the name of the services to delete
cf services | grep -e 'cloud' | awk '{print $1}' > "$DBS"
#Remove a specific service that should not be deleted
sed -i '/cloud-blob-storage/d' "$DBS"

#Setting the specific variables and configurations based on the ORG and SPACE selected
UnDeployment() {
    if [ "$REMOVE_APP" = true ]; then
        for app in $(cat $APP); do
            echo "---"
            echo "Deleting $app"
            cf stop "$app"
            sleep 1
            cf delete -r -f "$app"
        done
    fi
    if [ "$SPACE" = "test" ] || [ "$SPACE" = "review" ] || [ "$SPACE" = "next" ]; then
        echo "The DBS in $SPACE are protected"
    else
        if [ "$REMOVE_DBS" = true ]; then
            for dbs in $(cat $DBS); do
                echo "---"
                echo "Deleting $dbs"
                cf delete-service -f "$dbs"
                sleep 1
                echo "$dbs"
            done
        fi
    fi
    cf delete-orphaned-routes -f
}

echo "DEVOPS Check: START UnDeployment process"

UnDeployment

if [ $? -eq 0 ]; then
    echo OK; RESULT="PASSED"
else
    echo FAIL; RESULT="FAILED"
fi

if [ "$RESULT" = 'FAILED' ]; then
    exit 1
fi
