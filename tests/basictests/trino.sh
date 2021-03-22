#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_trino() {
    header "Testing Trino installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"

    for component in "hive-metastore" "trino-coordinator" "trino-worker";
    do
        os::cmd::try_until_text "oc get deployment $component" "$component" $odhdefaulttimeout $odhdefaultinterval
        os::cmd::try_until_text "oc get pods -l role=$component --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "$component" $odhdefaulttimeout $odhdefaultinterval
        runningpods=($(oc get pods -l deployment=$component --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
        os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    done
}

test_trino

os::test::junit::declare_suite_end
