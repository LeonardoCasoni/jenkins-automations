#!/bin/bash -u

echo 'DEVOPS Check: Start pre code script'

export PATH=$PATH:$(pwd)/node_modules/grunt-cli/bin
which grunt || echo "Installing grunt-cli" && npm install -g grunt-cli
which gulp || echo "Installing gulp-cli" && npm install -g gulp-cli
which pm2 || echo "Installing pm2" && npm install -g pm2

gulp -v
grunt -V
pm2 -v

#Install all required packages
npm install
echo 'DEVOPS Check: Pre code script finished'