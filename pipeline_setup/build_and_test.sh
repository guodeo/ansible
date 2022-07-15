#!/bin/bash

export DOCKER_SCAN_SUGGEST=false

if [[ -z $1 ]];
then
    echo "You must specify the directory for test result output when running this script e.g. './TestResults' "   
    exit 1
fi

outputPath=$1 #'./TestResults' or '$(Common.TestResultsDirectory)'
echo "TestResults Path is : $outputPath"
rm -r $outputPath
mkdir $outputPath

# run unit tests and copy results to host
docker build --target testrunner -t frontend-testrunner:latest .
docker run --name some-frontend-testrunner frontend-testrunner:latest
docker cp "some-frontend-testrunner:/app/apps/frontend/unitTestResults.xml" ${outputPath}
docker stop some-frontend-testrunner
docker rm some-frontend-testrunner

# run cypress tests and copy results to host
docker build --target e2etestrunner -t frontend-cypresstestrunner:latest .
exec 3>&2
exec 2> error.log
docker run --name some-frontend-cypresstestrunner frontend-cypresstestrunner:latest
exec 2>&3
docker cp "some-frontend-cypresstestrunner:/app/apps/frontend-e2e/cypressTestResults.xml" ${outputPath}
docker stop some-frontend-cypresstestrunner
docker rm some-frontend-cypresstestrunner

# build frontend
docker build -t frontend:latest .
