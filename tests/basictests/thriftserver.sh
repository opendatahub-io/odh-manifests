#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_thriftserver() {
    header "Testing ODH Hue installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get deployment thriftserver" "thriftserver" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l deployment=thriftserver --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "thriftserver" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l deployment=thriftserver --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

test_thriftserver

os::test::junit::declare_suite_end
