#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_grafana() {
    header "Testing ODH Grafana installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get deployment grafana-operator" "grafana-operator" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l name=grafana-operator --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "grafana-operator" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l name=grafana-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    os::cmd::try_until_text "oc get pods -l app=grafana --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "grafana-deployment" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l app=grafana --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    os::cmd::try_until_text "oc get grafanadashboard" "odh-kafka" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get grafanadatasource" "odh-datasource" $odhdefaulttimeout $odhdefaultinterval
}

test_grafana

os::test::junit::declare_suite_end
