#!/bin/bash

set -x
env | sort
mkdir -p ~/.kube
cp /var/run/secrets/ci.openshift.io/multi-stage/kubeconfig ~/.kube/config
chmod 755 ~/.kube/config
export KUBECONFIG=~/.kube/config
/peak/install.sh
/peak/operator-tests/run.sh
if [ "$?" -ne 0 ]; then
    echo "The tests failed"
    exit 1
fi
