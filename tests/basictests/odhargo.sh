#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util
HELLOWORD_CR="${MY_DIR}/../resources/argo-hello-world.yaml"


os::test::junit::declare_suite_start "$MY_SCRIPT"

function run_helloworld() {
    os::cmd::expect_success "oc create -f ${HELLOWORD_CR}"
    header "The hello world example should complete a hello-world workflow with success"
    os::cmd::try_until_text 'oc get workflow -o jsonpath="{$.items[*].status.phase}"' "Succeeded"
}


function test_odhargo() {
    header "Testing ODH Argo installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get deployment argo-server" "argo-server" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l app=argo-server --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "argo-server" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l app=argo-server --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    os::cmd::try_until_text "oc get pods -l app=workflow-controller --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "workflow-controller" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l app=workflow-controller --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    run_helloworld
}

test_odhargo

os::test::junit::declare_suite_end
