#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

JH_LOGIN_USER=${OPENSHIFT_USER:-"admin"} #Username used to login to JH
JH_LOGIN_PASS=${OPENSHIFT_PASS:-"admin"} #Password used to login to JH
OPENSHIFT_LOGIN_PROVIDER=${OPENSHIFT_LOGIN_PROVIDER:-"htpasswd-provider"} #OpenShift OAuth provider used for login
JH_AS_ADMIN=${JH_AS_ADMIN:-"true"} #Expect the user to be Admin in JupyterHub

JUPYTER_IMAGES=(s2i-minimal-notebook:v0.0.4 s2i-scipy-notebook:v0.0.1 s2i-tensorflow-notebook:v0.0.1 s2i-spark-minimal-notebook:py36-spark2.4.5-hadoop2.7.3)
JUPYTER_NOTEBOOK_FILES=(basic.ipynb basic.ipynb tensorflow.ipynb spark.ipynb)

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_jupyterhub() {
    header "Testing JupyterHub installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get deploymentconfig jupyterhub" "jupyterhub" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get deploymentconfig jupyterhub-db" "jupyterhub-db" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l deploymentconfig=jupyterhub --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "jupyterhub" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l deploymentconfig=jupyterhub --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    os::cmd::try_until_text "oc get pods -l deploymentconfig=jupyterhub-db --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "jupyterhub-db" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l deploymentconfig=jupyterhub-db --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

function test_start_notebook() {
    local notebook_name=$1
    local notebook_file=$2
    local user=$3
    local size=${4-Small}

    header "Testing Jupyter Notebook ${notebook_name} Execution (Size: ${size})"

    os::cmd::expect_success "oc project ${ODHPROJECT}"
    route="https://"$(oc get route jupyterhub -o jsonpath='{.spec.host}')
    os::cmd::expect_success "JH_HEADLESS=true JH_USER_NAME=${user} JH_LOGIN_USER=${JH_LOGIN_USER} JH_LOGIN_PASS=${JH_LOGIN_PASS} OPENSHIFT_LOGIN_PROVIDER=${OPENSHIFT_LOGIN_PROVIDER} \
    JH_NOTEBOOKS=${notebook_file} JH_NOTEBOOK_IMAGE=${notebook_name} JH_AS_ADMIN=${JH_AS_ADMIN} \
    JH_URL=${route} JH_NOTEBOOK_SIZE=${size} \
    python3 ${MY_DIR}/jupyterhub/jhtest.py"
}

function test_notebooks() {
    for index in ${!JUPYTER_IMAGES[*]}; do
        test_start_notebook ${JUPYTER_IMAGES[$index]} testing-notebooks/${JUPYTER_NOTEBOOK_FILES[$index]} jh-test${index}
    done
}

test_jupyterhub
test_notebooks

os::test::junit::declare_suite_end
