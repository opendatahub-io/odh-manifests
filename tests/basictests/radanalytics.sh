#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_spark_operator_install() {
    header "Testing Radanalytics Spark Operator installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::expect_success_and_text "oc get deployment spark-operator" "spark-operator"
    runningpods=($(oc get pods -l app.kubernetes.io/name=spark-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

test_spark_operator_install


os::test::junit::declare_suite_end
