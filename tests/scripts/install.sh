#!/bin/bash

echo "Installing kfDef from test directory"

set -x
pushd /kfdef
echo "Setting manifests in kfctl_openshift to use sha: $PULL_PULL_SHA"
sed -i "s#uri: https://github.com/opendatahub-io/odh-manifests/tarball/master#uri: https://github.com/opendatahub-io/odh-manifests/tarball/$PULL_PULL_SHA#" ./kfctl_openshift.yaml
kfctl build -V -f ./kfctl_openshift.yaml
kfctl apply -V -f ./kfctl_openshift.yaml
set +x
if [ "$?" -ne 0 ]; then
    echo "The installation failed"
    exit $?
fi
popd

echo "Pausing 240 seconds to allow services to spin-up"
sleep 240s
