#!/bin/bash

echo "Installing kfDef from test directory"

set -x
## Grabbing and applying the patch in the PR we are testing
pushd /src/odh-manifests
curl -O https://github.com/${REPO_OWNER}/${REPO_NAME}/pull/${PULL_NUMBER}.patch
git apply ${PULL_NUMBER}.patch
popd
## Point kfctl_openshift.yaml to the manifests in the PR
pushd /kfdef
echo "Setting manifests in kfctl_openshift to use sha: $PULL_PULL_SHA"
sed -i "s#uri: https://github.com/opendatahub-io/odh-manifests/tarball/master#uri: /src/odh-manifests#" ./kfctl_openshift.yaml
kfctl build -V -f ./kfctl_openshift.yaml
kfctl apply -V -f ./kfctl_openshift.yaml
set +x
if [ "$?" -ne 0 ]; then
    echo "The installation failed"
    exit $?
fi
popd

echo "Pausing 3 hours to allow debugging"
sleep 3h
