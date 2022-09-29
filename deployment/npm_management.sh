#!/bin/bash -u

npm install

#This could be a step in case you cannot use npm directly, but for example grunt workflows
if [ "${ORG}" == "iot" ]; then
    # temp fix to install grunt without root privileges
    export PATH=$PATH:$(pwd)/node_modules/grunt-cli/bin:$(pwd)
    which grunt || npm i grunt-cli

    npm install grunt --save-dev

    npm install --production

    nodejs --version
    npm --version
    grunt --version

    npm install --production
fi

rm -rf .npmrc
