#!/bin/bash

set -x
env | sort
mkdir -p ~/.kube
cp /var/run/secrets/ci.openshift.io/multi-stage/kubeconfig ~/.kube/config
chmod 755 ~/.kube/config
export KUBECONFIG=~/.kube/config
# This is needed to avoid `oc status` failing inside openshift-ci
oc new-project opendatahub
/peak/install.sh
/peak/run.sh odh-manifests
if [ "$?" -ne 0 ]; then
    echo "Here's a dump of the pods:"
    oc get pods -o json -n opendatahub 
    echo "The tests failed"
    exit 1
fi
## Debugging pause...uncomment below to be able to poke around the test pod post-test
# echo "Debugging pause for 3 hours"
# sleep 180m
