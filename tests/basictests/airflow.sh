#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_airflow() {
    header "Testing Airflow installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::expect_success_and_text "oc get deployment airflow-on-k8s-operator-controller-manager" "airflow-on-k8s-operator-controller-manager"
    runningpods=($(oc get pods -l control-plane=controller-manager --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

test_airflow

os::test::junit::declare_suite_end
