#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
KAFKA_TEST_JOB="${MY_DIR}/../resources/kafka-test.job.yaml"

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_kafka() {
    header "Testing ODH Strimzi Kafka installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get deployments -n openshift-operators" "strimzi-cluster-operator" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -n openshift-operators -l name=strimzi-cluster-operator --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "strimzi-cluster-operator" $odhdefaulttimeout $odhdefaultinterval
    runningbuspods=($(oc get pods -n openshift-operators -l name=strimzi-cluster-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningbuspods[@]}" "1"
    os::cmd::try_until_text "oc get kafka" "odh-message-bus" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get deployments" "odh-message-bus-entity-operator" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l app.kubernetes.io/instance=odh-message-bus --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "odh-message-bus-entity-operator" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l app.kubernetes.io/instance=odh-message-bus --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "odh-message-bus-kafka" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l app.kubernetes.io/instance=odh-message-bus --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "odh-message-bus-zookeeper" $odhdefaulttimeout $odhdefaultinterval
    runningbuspods=($(oc get pods -l app.kubernetes.io/instance=odh-message-bus --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningbuspods[@]}" "7"
}

function test_kafka_consumer_producer() {
    oc apply -n "${ODHPROJECT}" -f ${KAFKA_TEST_JOB}
    os::cmd::try_until_text "oc logs -l job-name=kafka-test" "Producer produced a message"
    oc delete -n "${ODHPROJECT}" -f ${KAFKA_TEST_JOB}
}

test_kafka
test_kafka_consumer_producer

os::test::junit::declare_suite_end
