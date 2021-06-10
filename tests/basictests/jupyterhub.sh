#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

JH_LOGIN_USER=${OPENSHIFT_USER:-"admin"} #Username used to login to JH
JH_LOGIN_PASS=${OPENSHIFT_PASS:-"admin"} #Password used to login to JH
OPENSHIFT_LOGIN_PROVIDER=${OPENSHIFT_LOGIN_PROVIDER:-"htpasswd-provider"} #OpenShift OAuth provider used for login
JH_AS_ADMIN=${JH_AS_ADMIN:-"true"} #Expect the user to be Admin in JupyterHub
ODS_CI_REPO_ROOT=${ODS_CI_REPO_ROOT:-"${HOME}/src/ods-ci"}

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

function test_ods_ci() {
    header "Running ODS-CI automation"

    os::cmd::expect_success "oc project ${ODHPROJECT}"
    ODH_JUPYTERHUB_URL="https://"$(oc get route jupyterhub -o jsonpath='{.spec.host}')
    pushd ${HOME}/src/ods-ci
    #TODO: Add a test that will iterate over all of the notebook using the notebooks in https://github.com/opendatahub-io/testing-notebooks
    os::cmd::expect_success "run_robot_test.sh --test-artifact-dir ${ARTIFACT_DIR} --test-case ${MY_DIR}/../resources/ods-ci/test-odh-jupyterlab-notebook.robot --test-variables-file ${MY_DIR}/../resources/ods-ci/test-variables.yml --test-variable 'ODH_JUPYTERHUB_URL:${ODH_JUPYTERHUB_URL}' --test-variable RESOURCE_PATH:${PWD}/tests/Resources"
    popd
}

test_jupyterhub
test_ods_ci

os::test::junit::declare_suite_end
