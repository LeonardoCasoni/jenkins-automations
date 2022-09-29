#!/bin/bash -u
#Example of integration test script


if [ "$INTEGRATION" = true ]; then
    echo 'DEVOPS Check: Setting up integration tests'
    cd utilities/integration-tests || exit 1
    npm install --force

    echo 'DEVOPS Check: Executing integration tests'
    gulp starttest

    cd - || exit 1

    echo 'DEVOPS Check: Setting up iot-modules for more tests'
    cd ../iot-modules/iot-integration-test-utils || exit 1
    npm install --force
    cd - || exit 1

    echo 'DEVOPS Check: Setting up IoT apps for more tests'
    cd ../iot-cloud || exit 1
    npm install --force

    grunt dev:install --force
    echo 'DEVOPS Check: grunt server start'
    pm2 list

    cd - || exit 1
    cd utilities/integration-tests || exit 1

    echo 'DEVOPS Check: Starting integration tests with IoT'
    gulp testwithiot

    cd - || exit 1
    echo 'DEVOPS Check: End of integration tests'
fi
