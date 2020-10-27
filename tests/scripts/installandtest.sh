#!/bin/bash

set -x
env | sort | tee ${ARTIFACT_DIR}/env.txt
mkdir -p ~/.kube
cp /tmp/kubeconfig ~/.kube/config 2> /dev/null || cp /var/run/secrets/ci.openshift.io/multi-stage/kubeconfig ~/.kube/config
chmod 644 ~/.kube/config
export KUBECONFIG=~/.kube/config

if [ ! -d "${ARTIFACT_DIR}/screenshots" ]; then
  ARTIFACT_SCREENSHOT_DIR="${ARTIFACT_DIR}/screenshots"
  echo "Creating the screenshot artifact directory: ${ARTIFACT_SCREENSHOT_DIR}"
  mkdir -p ${ARTIFACT_SCREENSHOT_DIR}
fi

TESTS_REGEX=${TESTS_REGEX:-"basictests"}
ODHPROJECT=${ODHPROJECT:-"opendatahub"}
export ODHPROJECT

echo "OCP version info"
echo `oc version`

if [ -z "${SKIP_INSTALL}" ]; then
    # This is needed to avoid `oc status` failing inside openshift-ci
    oc new-project ${ODHPROJECT}
    $HOME/peak/install.sh
    echo "Sleeping for 5 min to let the KfDef install settle"
    sleep 5m
fi
$HOME/peak/run.sh ${TESTS_REGEX}

if  [ "$?" -ne 0 ]; then
    echo "The tests failed"
    if [ -z "${SKIP_PODS_OUTPUT}" ]; then
        echo "Saving the dump of the pods logs in the artifacts directory"
        oc get pods -o json -n ${ODHPROJECT} > ${ARTIFACT_DIR}/${ODHPROJECT}.pods.yaml
        echo "Saving the logs from the opendatahub-operator pod in the artifacts directory"
        oc logs -n openshift-operators $(oc get pods -n openshift-operators -l name=opendatahub-operator -o jsonpath="{$.items[*].metadata.name}") > ${ARTIFACT_DIR}/opendatahub-operator.log
    fi
    exit 1
fi

## Debugging pause...uncomment below to be able to poke around the test pod post-test
# echo "Debugging pause for 3 hours"
#sleep 180m
