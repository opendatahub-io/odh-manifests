#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_jupyterhub() {
    header "Testing Jupyter Hub installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::expect_success_and_text "oc get deploymentconfig jupyterhub" "jupyterhub"
    os::cmd::expect_success_and_text "oc get deploymentconfig jupyterhub-db" "jupyterhub-db"
    runningpods=($(oc get pods -l deploymentconfig=jupyterhub --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    runningpods=($(oc get pods -l deploymentconfig=jupyterhub-db --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

test_jupyterhub

os::test::junit::declare_suite_end
