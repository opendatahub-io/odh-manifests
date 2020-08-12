#!/bin/bash

set -x
env | sort
mkdir -p ~/.kube
cp /tmp/kubeconfig ~/.kube/config 2> /dev/null || cp /var/run/secrets/ci.openshift.io/multi-stage/kubeconfig ~/.kube/config
chmod 644 ~/.kube/config
export KUBECONFIG=~/.kube/config

TESTS_REGEX=${TESTS_REGEX:-"basictests"}
ODHPROJECT=${ODHPROJECT:-"opendatahub"}
export ODHPROJECT

if [ -z "${SKIP_INSTALL}" ]; then
    # This is needed to avoid `oc status` failing inside openshift-ci
    oc new-project ${ODHPROJECT}
    $HOME/peak/install.sh
fi
$HOME/peak/run.sh ${TESTS_REGEX}

if  [ "$?" -ne 0 ]; then
    echo "The tests failed"
    if [ -z "${SKIP_PODS_OUTPUT}" ]; then
        echo "Here's a dump of the pods:"
        oc get pods -o json -n ${ODHPROJECT}
    fi
    exit 1
fi

## Debugging pause...uncomment below to be able to poke around the test pod post-test
# echo "Debugging pause for 3 hours"
# sleep 180m
