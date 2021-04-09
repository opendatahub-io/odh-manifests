#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

OPENSHIFT_PIPELINES_RESOURCES_DIR="${MY_DIR}/../resources/openshift-pipelines"
TASK_CR="${OPENSHIFT_PIPELINES_RESOURCES_DIR}/task-hello-world.yaml"
PIPELINE_CR="${OPENSHIFT_PIPELINES_RESOURCES_DIR}/pipeline-hello-world.yaml"
PIPELINERUN_CR="${OPENSHIFT_PIPELINES_RESOURCES_DIR}/pipelinerun-hello-world.yaml"

function verify_openshift_pipelines_operator_install() {
    header "Testing OpenShift Pipelines operator installation"
    os::cmd::expect_success_and_text "oc get deployment -n openshift-operators openshift-pipelines-operator" "openshift-pipelines-operator"
    runningpods=($(oc get pods -n openshift-operators -l name=openshift-pipelines-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

function create_openshift_pipelines_objects() {
    header "Create OpenShift Pipelines"
    os::cmd::expect_success "oc apply -f ${TASK_CR}"
    os::cmd::try_until_not_text "oc get task odh-test-hello-world" "not found"

    os::cmd::expect_success "oc apply -f ${PIPELINE_CR}"
    os::cmd::try_until_not_text "oc get pipeline odh-test-hello-world" "not found"

    os::cmd::expect_success "oc create -f ${PIPELINERUN_CR}"
}

function test_openshift_pipelines_functionality() {
    header "Testing OpenShift Pipelines functionality"
    os::cmd::expect_success "oc project ${ODHPROJECT}"

    verify_openshift_pipelines_operator_install
    create_openshift_pipelines_objects

}

test_openshift_pipelines_functionality

os::test::junit::declare_suite_end
