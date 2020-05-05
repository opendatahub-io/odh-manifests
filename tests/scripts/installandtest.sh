#!/bin/bash

set -x
env | sort
cp /var/run/secrets/ci.openshift.io/multi-stage/kubeconfig /root/.kube/config
chmod 755 /root/.kube/config
export KUBECONFIG=/root/.kube/config
/peak/install.sh
/peak/operator-tests/run.sh
if [ "$?" -ne 0 ]; then
    echo "The tests failed"
    exit 1
fi
