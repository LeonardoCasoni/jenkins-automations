#!/bin/bash -u

echo "DEVOPS Check: Creating variables"

#For safety reason, I will set to false all the options for non develop environments
if  [ "$SPACE" = "next" ] || [ "$SPACE" = "staging" ] || [ "$SPACE" = "production" ]; then
    echo "You are trying to deploy redgreen a blocked environmentm so I have to exit"
    exit 1
fi

APP=app.txt
APPTMP=applist.tmp
APPLIST=applist.txt
YAMLLIST=yamllist.txt

GitDiff() {
    cd "$ORG"/versioning/"$SPACE" || exit 1
    count=$(ls -1 *.yaml 2>/dev/null | wc -l)
    if [ "$count" != 0 ]; then
        ls *.yaml >> "$YAMLLIST"

        #Parsing the yaml files to get the app names
        for yamlfile in $(cat $YAMLLIST); do
            awk '/^[^ ]/{f=/^- apps:/; next} f' "$yamlfile" | awk '!a[$0]++' | grep -e "services" | sed 's/\ - //' | sed 's/\//-/g' | sed 's/_/-/g' | sed 's/.$//g' | sed "s/services/$ORG/g" >> "$APPTMP"
        done

        #Check if there are duplicates apps to remove them just one time
        awk '!seen[$0]++' "$APPTMP" > "$APPLIST"

        #Use the app name to get he right name with version to delete from cf
        for appname in $(cat $APPLIST); do
            #Options to manage app with server in the name 
            if echo "$appname" | grep -e "server"; then
                RIGHTNAME=$(echo "$appname" | sed 's/-server//g')
                cf a | grep -e "$RIGHTNAME-[0-9]" | awk '{print $1}' >> "$APP"
            else
                cf a | grep -e "$appname" | awk '{print $1}' >> "$APP"
            fi
        done
    else
        echo "No YAML file found"
        exit 1
    fi
}

RedGreen() {
    if [ "$SERVICE" = "versioning" ]; then
        GitDiff
        #Start deleting apps detected with versioning workflow
        for app in $(cat $APP); do
            echo "Deleting $app"
            cf stop "$app"
            sleep 1
            cf delete -r -f "$app"
        done
    else
        #Deleting apps provided during the Jenkins job triggering phase
        for app in $SERVICE; do
            echo "Deleting $app"
            cf stop "$app"
            sleep 1
            cf delete -r -f "$app"
        done
    fi
    cf delete-orphaned-routes -f
}

echo "DEVOPS Check: START RedGreen deployment"

RedGreen

#Formatting the $APPLIST for the confluence page
cp -apu "$APPLIST" mod.temp
sed -i 's/$/ /g' mod.temp
tr -d "\n\r" < mod.temp > "$APPLIST"

if [ $? -eq 0 ]; then
    echo OK; RESULT="PASSED"
else
    echo FAIL; RESULT="FAILED"
fi

if [ "$RESULT" = 'FAILED' ]; then
    exit 1
fi