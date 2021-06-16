#!/usr/bin/env bash

DEV=`curl -s https://dev-api.va.gov/v0/status  | jq -r .git_revision`
STAGING=`curl -s https://staging-api.va.gov/v0/status  | jq -r .git_revision`
PROD=`curl -s https://api.va.gov/v0/status  | jq -r .git_revision`
echo "development:"
echo "SHA:" $DEV
echo `git show -s --format="Date: %ci Author: %an Subject: %s" $DEV`
echo

echo "Staging:"
echo "SHA:" $STAGING
echo -e `git show -s --format="Date: %ci Author: %an Subject: %s" $STAGING`
echo

echo "prod:"
echo "SHA:" $PROD
echo "tags:"
echo `git tag --contains $PROD`
echo `git show -s --format="Date: %ci Author: %an Subject: %s" $PROD`
