#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_prometheus() {
    header "Testing ODH Prometheus installation"
    os::cmd::try_until_text "oc get pods -l k8s-app=prometheus-operator --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "prometheus-operator" odhdefaulttimeout
    runningbuspods=($(oc get pods -l k8s-app=prometheus-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningbuspods[@]}" "1"
    os::cmd::try_until_text "oc get pods -l app=prometheus --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "prometheus-prometheus" odhdefaulttimeout
    runningbuspods=($(oc get pods -l app=prometheus --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningbuspods[@]}" "1"
}

test_prometheus

os::test::junit::declare_suite_end
