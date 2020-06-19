#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util
SELDONMODEL_CR="${MY_DIR}/../resources/seldon-model.json"

os::test::junit::declare_suite_start "$MY_SCRIPT"

function run_servemodel() {
    os::cmd::expect_success "oc create -f ${SELDONMODEL_CR}"
    header "The seldon model example should create a successful seldondeployment"
    os::cmd::try_until_text 'oc get seldondeployment -o jsonpath="{$.items[*].status.state}"' "Available"
}

function test_seldon() {
    header "Testing ODH Seldon installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    runningpods=($(oc get pods -l app=seldon --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    run_servemodel
}

test_seldon

os::test::junit::declare_suite_end
