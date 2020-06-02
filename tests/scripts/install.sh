#!/bin/bash

echo "Installing kfDef from test directory"

set -x
## Install the opendatahub-operator
pushd /peak
./setup.sh -o /peak/operatorsetup 2>&1
echo "Pausing 20 seconds to allow operator to start"
sleep 20s
popd
## Grabbing and applying the patch in the PR we are testing
pushd /src/odh-manifests
if [ -z "$PULL_NUMBER" ]; then
  echo "No pull number, assuming nightly run"
else
  curl -O -L https://github.com/${REPO_OWNER}/${REPO_NAME}/pull/${PULL_NUMBER}.patch
  echo "Applying followng patch:"
  cat ${PULL_NUMBER}.patch
  git apply ${PULL_NUMBER}.patch
fi
popd
## Point kfctl_openshift.yaml to the manifests in the PR
pushd /kfdef
if [ -z "$PULL_NUMBER" ]; then
  echo "No pull number, not modifying kfctl_openshift.yaml"
else
  echo "Setting manifests in kfctl_openshift to use pull number: $PULL_NUMBER"
  sed -i "s#uri: https://github.com/opendatahub-io/odh-manifests/tarball/master#uri: https://api.github.com/repos/opendatahub-io/odh-manifests/tarball/pull/${PULL_NUMBER}/head#" ./kfctl_openshift.yaml
fi
echo "Creating the following KfDef"
cat ./kfctl_openshift.yaml
oc create -f ./kfctl_openshift.yaml
set +x
if [ "$?" -ne 0 ]; then
    echo "The installation failed"
    exit $?
fi
popd

echo "Pausing 300 seconds to allow services to spin-up"
sleep 300s
