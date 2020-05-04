#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_superset() {
    header "Testing ODH Superset installation"
    os::cmd::expect_success "oc project opendatahub"
    os::cmd::expect_success_and_text "oc get deploymentconfig superset" "superset"
    runningpods=($(oc get pods -l app=superset --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

test_superset

os::test::junit::declare_suite_end
