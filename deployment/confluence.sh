#!/bin/bash -u
#This script should be used providing the environmental variables ORG, SPACE, GIT_REF, VERSION and RESULT.

#Defiying general variables
JSONNAME='deployment/confluence_page.json'
JSONMAIN='deployment/confluence_main.json'
DATE=$(date +%d-%m-%Y)
TIME=$(date +%T)

#Defiying the correct Confluence's page to update

if [ "$ORG-$SPACE" = "iot-test" ]; then
  PAGEID=213
  CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "iot-review" ]; then
    PAGEID=231
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "iot-next" ]; then
    PAGEID=3242
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "iot-staging" ]; then
    PAGEID=234
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "iot-production" ]; then
    PAGEID=45
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "cloud-develop" ]; then
  	PAGEID=456
  	CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "cloud-test" ]; then
    PAGEID=567
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "cloud-review" ]; then
    PAGEID=2143
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "cloud-next" ]; then
    PAGEID=356
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "cloud-staging" ]; then
    PAGEID=467
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  elif [ "$ORG-$SPACE" = "cloud-production" ]; then
    PAGEID=234
    CONFL_URL="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID"
  else
    echo "No $ORG-$SPACE found"
    exit 1
fi

#Download the content of the page
OLDCONTENT=$(curl -u "$CONFL_USER_NAME":"$CONFL_USER_PASSWORD" -X GET "$CONFL_URL?expand=body.storage" | python -mjson.tool | grep value | sed 's/\"//g' | sed 's/^.*value/value/g' | sed 's/value:\ //g' | sed 's+<+\\<+g' | sed 's+>+\\>+g' | sed 's+\ +\\\ +g' | sed 's+\/+\\\/+g')
echo "DEVOPS Check: Start oldcontent"
echo "$OLDCONTENT"
echo "DEVOPS Check: End oldcontent"

if [ "$SERVICE" = "all" ]; then
  SERVICE_LIST="all the apps"
  else
  SERVICE_LIST="$SERVICE"
fi

#Create the string of the new content we are going to add in the page
GIT_REF_FORMATTED=$(echo "$GIT_REF" | sed 's+\/+\\\/+g')

if [ "$RESULT" = "SUCCESS" ]; then
NEWCONTENT="\<strong\>$RESULT\<\/strong\> deployment \
of \<strong\>$ORG-$SPACE\<\/strong\> version \<strong\>$VERSION\<\/strong\> and-or GIT_REF $GIT_REF_FORMATTED on $TIME $DATE with $SERVICE_LIST" #with $RELEASE_LINK"
  else
  NEWCONTENT="\<strong\>$RESULT\<\/strong\> deployment of \<strong\>$ORG-$SPACE\<\/strong\> version \<strong\>$VERSION\<\/strong\> and-or GIT_REF $GIT_REF_FORMATTED on $TIME $DATE with $SERVICE_LIST" #with $RELEASE_LINK"
fi

#Determine the version of the page to get the next incremental number
VERSION_NUM=$(curl -u "$CONFL_USER_NAME":"$CONFL_USER_PASSWORD" -X GET "$CONFL_URL?expand=version.number" |\
python -mjson.tool | grep number | sed 's/\ //g' | sed 's/\"number\"://g' | sed 's/\,//g')
declare -i VERSION_UP=$(("$VERSION_NUM" + 1))

#Make a copy of the $JSONNAME for the next steps
cp -apu $JSONNAME $JSONMAIN
echo "DEVOPS Check: Cat of the 2 Json files"
cat "$JSONNAME"
cat "$JSONMAIN"
echo "DEVOPS Check: End cat of the 2 Json files"

#Formatting the json file to be used in the updating process
sed -i "s/AAA/\<p\>$NEWCONTENT\<\/p\>$OLDCONTENT/g" $JSONNAME
sed -i "s/BBB/$VERSION_UP/g" $JSONNAME
sed -i "s/CCC/$PAGEID/g" $JSONNAME
sed -i "s/DDD/$ORG-$SPACE/g" $JSONNAME
echo "DEVOPS Check: Cat jsonname"
cat "$JSONNAME"
echo "DEVOPS Check: End cat jsonname"

#Updating the Confluence's page with the defined data
curl -u "$CONFL_USER_NAME":"$CONFL_USER_PASSWORD" -X PUT -H 'Content-Type:application/json' -d @"$JSONNAME" "$CONFL_URL"

#Making the same steps in case of SUCCESS result to upload the main page
if [ "$RESULT" = "SUCCESS" ]; then
  PAGEID_MAIN="283446107"
  CONFL_URL_MAIN="$CONFLUENCE_BASE"/rest/api/content/"$PAGEID_MAIN"

  #Determine the versione of the page to get the next incremental number
  declare -i VERSION_NUM_MAIN=$(curl -u "$CONFL_USER_NAME":"$CONFL_USER_PASSWORD" -X GET "$CONFL_URL_MAIN?expand=version.number" | python -mjson.tool | grep number | sed 's/\ //g' | sed 's/\"number\"://g' | sed 's/\,//g')
  declare -i VERSION_UP_MAIN=$(("$VERSION_NUM_MAIN" + 1))

  #Download the content of the page
  OLDCONTENT_MAIN=$(curl -u "$CONFL_USER_NAME":"$CONFL_USER_PASSWORD" -X GET "$CONFL_URL_MAIN?expand=body.storage" | python -mjson.tool | grep value | sed 's/\"//g' | sed 's/^.*value/value/g' | sed 's/value:\ //g' | sed 's+<+\\<+g' | sed 's+>+\\>+g' | sed 's+\ +\\\ +g' | sed 's+\/+\\\/+g')
  echo "DEVOPS Check: Start oldcontent_main"
  echo "$OLDCONTENT_MAIN"
  echo "DEVOPS Check: End oldcontent_main"

  #Formatting the json file to be used in the updating process
  sed -i "s/AAA/\<p\>$NEWCONTENT\<\/p\>$OLDCONTENT_MAIN/g" $JSONMAIN
  sed -i "s/BBB/$VERSION_UP_MAIN/g" $JSONMAIN
  sed -i "s/CCC/$PAGEID_MAIN/g" $JSONMAIN
  sed -i "s/DDD/Deployment\ history/g" $JSONMAIN
  echo "DEVOPS Check: Cat jsonmain"
  cat "$JSONMAIN"
  echo "DEVOPS Check: end cat jsonmain"

  #Updating the Confluence's page with the defined data
  curl -u "$CONFL_USER_NAME":"$CONFL_USER_PASSWORD" -X PUT -H 'Content-Type:application/json' -d @"$JSONMAIN" "$CONFL_URL_MAIN"
fi
