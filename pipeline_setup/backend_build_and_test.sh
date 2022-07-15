#!/bin/bash

if [[ -z $1 ]];
then
    echo "You must specify the location of TestResults to run this script e.g. locally this would be ./build_and_release.sh './TestResults' "   
    exit 1
fi

outputPath=$1 #'./TestResults' or '$(Common.TestResultsDirectory)'
echo "TestResults Path is : $outputPath"
rm -r $outputPath
mkdir $outputPath

# tidy up if running and/or exists
docker ps -q --filter "name=some-compassapi" | grep -q . && docker stop some-compassapi && docker rm -fv some-compassapi
docker ps -q --filter "name=some-compassapi-testrunner" | grep -q . && docker stop some-compassapi-testrunner && docker rm -fv some-compassapi-testrunner
docker ps -q --filter "name=some-compassapi-componenttestrunner" | grep -q . && docker stop some-compassapi-componenttestrunner && docker rm -fv some-compassapi-componenttestrunner

# build api
docker build -t compassapi:latest .

# run tests and copy results to host
docker build --target testrunner -t compassapi-testrunner:latest .
docker run --name some-compassapi-testrunner compassapi-testrunner:latest
docker cp "some-compassapi-testrunner:/app/publish/tests" ${outputPath}

# run component tests and copy results to host
docker build --target componenttestrunner -t compassapi-componenttestrunner:latest .
docker run --name some-compassapi -d -p 6000:6000 compassapi:latest 
docker run -e "Url=http://localhost:6000" --network=host --name some-compassapi-componenttestrunner compassapi-componenttestrunner:latest
docker cp "some-compassapi-componenttestrunner:/app/publish/componenttests" ${outputPath}

# tidy up
docker stop some-compassapi
docker rm some-compassapi
docker rm some-compassapi-testrunner
docker rm some-compassapi-componenttestrunner
