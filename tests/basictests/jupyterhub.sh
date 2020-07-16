#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

JH_LOGIN_USER=${OPENSHIFT_USER:-"admin"} #Username used to login to JH
JH_LOGIN_PASS=${OPENSHIFT_PASS:-"admin"} #Password used to login to JH
OPENSHIFT_LOGIN_PROVIDER=${OPENSHIFT_LOGIN_PROVIDER:-"htpasswd-provider"} #OpenShift OAuth provider used for login
JH_AS_ADMIN=${JH_AS_ADMIN:-"true"} #Expect the user to be Admin in JupyterHub

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
    header "Testing JupyterHub Notebook Execution"

    os::cmd::expect_success "oc project ${ODHPROJECT}"
    route="https://"$(oc get route jupyterhub -o jsonpath='{.spec.host}')
    os::cmd::expect_success "JH_HEADLESS=true JH_USER_NAME=jh-test JH_LOGIN_USER=${JH_LOGIN_USER} JH_LOGIN_PASS=${JH_LOGIN_PASS} OPENSHIFT_LOGIN_PROVIDER=${OPENSHIFT_LOGIN_PROVIDER} \
    JH_NOTEBOOKS=jh-stresstest/test.ipynb JH_NOTEBOOK_IMAGE=s2i-minimal-notebook:3.6 JH_AS_ADMIN=${JH_AS_ADMIN} \
    JH_URL=$route python3 ${MY_DIR}/jupyterhub/jhtest.py"
}

test_jupyterhub
test_start_notebook

os::test::junit::declare_suite_end
