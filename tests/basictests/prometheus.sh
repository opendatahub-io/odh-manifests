#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_promportal() {
    # Check that the UI is indeed up by curling the route
    uiroute=$(oc get route prometheus-portal -o jsonpath="{$.status.ingress[0].host}")
    os::cmd::try_until_text "curl -s -D - -o /dev/null http://$uiroute/graph" "HTTP/1.1 200 OK"
}

function test_prometheus() {
    header "Testing ODH Prometheus installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get pods -l k8s-app=prometheus-operator --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "prometheus-operator" $odhdefaulttimeout $odhdefaultinterval
    runningbuspods=($(oc get pods -l k8s-app=prometheus-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningbuspods[@]}" "1"
    os::cmd::try_until_text "oc get pods -l app=prometheus --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "prometheus-prometheus" $odhdefaulttimeout $odhdefaultinterval
    runningbuspods=($(oc get pods -l app=prometheus --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningbuspods[@]}" "1"
    test_promportal
}

test_prometheus

os::test::junit::declare_suite_end
