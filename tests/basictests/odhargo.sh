#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_odhargo() {
    header "Testing ODH Argo installation"
    os::cmd::expect_success "oc project opendatahub"
    os::cmd::expect_success_and_text "oc get deployment argo-server" "argo-server"
    runningpods=($(oc get pods -l app=argo-server --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    runningpods=($(oc get pods -l app=workflow-controller --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

test_odhargo

os::test::junit::declare_suite_end
