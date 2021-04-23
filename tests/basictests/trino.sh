#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_hive_metastore() {
    header "Testing Hive Metastore installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get statefulset hive-metastore" "hive-metastore" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l hive=metastore --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "hive-metastore" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l hive=metastore --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

function test_trino() {
    header "Testing Trino installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"

    for component in "trino-coordinator" "trino-worker";
    do
        os::cmd::try_until_text "oc get deployment $component" "$component" $odhdefaulttimeout $odhdefaultinterval
        os::cmd::try_until_text "oc get pods -l role=$component --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "$component" $odhdefaulttimeout $odhdefaultinterval
        runningpods=($(oc get pods -l role=$component --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
        if [ $component == "trino-coordinator" ];
        then
            os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
        else
            os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "3"
        fi

    done
}

test_hive_metastore
test_trino

os::test::junit::declare_suite_end
