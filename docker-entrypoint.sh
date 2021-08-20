#!/bin/bash -e

# note this logic is duplicated in the Dockerfile for prod builds,
# if you make major alteration here, please check that usage as well
curl -LO http://archive.ubuntu.com/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb
dpkg -i libffi6_3.2.1-8_amd64.deb

bundle check || bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin" --jobs=4 --deployment


exec "$@"

if [ -e  "./docker_debugging" ] ; then
  echo starting rake docker_debugging:setup
  rake docker_debugging:setup
fi

