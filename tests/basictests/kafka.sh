#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_kafka() {
    header "Testing ODH Strimzi Kafka installation"
    os::cmd::expect_success "oc project opendatahub"
    os::cmd::expect_success_and_text "oc get deployments -n openshift-operators" "strimzi-cluster-operator"
    runningbuspods=($(oc get pods -n openshift-operators -l name=strimzi-cluster-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningbuspods[@]}" "1"
    os::cmd::expect_success_and_text "oc get kafka" "odh-message-bus"
    os::cmd::expect_success_and_text "oc get deployments" "odh-message-bus-entity-operator"
    runningbuspods=($(oc get pods -l app.kubernetes.io/instance=odh-message-bus --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningbuspods[@]}" "7"
}

test_kafka

os::test::junit::declare_suite_end
