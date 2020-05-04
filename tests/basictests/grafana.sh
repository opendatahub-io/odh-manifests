#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_grafana() {
    header "Testing ODH Grafana installation"
    os::cmd::expect_success "oc project opendatahub"
    os::cmd::expect_success_and_text "oc get deployment grafana-operator" "grafana-operator"
    runningpods=($(oc get pods -l name=grafana-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    runningpods=($(oc get pods -l app=grafana --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    os::cmd::expect_success_and_text "oc get grafanadashboard" "odh-kafka"
    os::cmd::expect_success_and_text "oc get grafanadatasource" "odh-datasource"
}

test_grafana

os::test::junit::declare_suite_end
