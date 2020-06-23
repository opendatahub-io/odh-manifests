#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

OPERATOR_IMAGE="quay.io/opendatahub/ai-library-operator:v0.6"

function test_ai_library() {
    header "Testing AI Library installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get deployment ailibrary-operator" "ailibrary-operator" odhdefaulttimeout
    os::cmd::try_until_text "oc get deployment ailibrary-operator -o jsonpath='{$.spec.template.spec.containers[0].image}'" ${OPERATOR_IMAGE} odhdefaulttimeout
    os::cmd::try_until_text "oc get pods -l name=ailibrary-operator --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "ailibrary-operator" odhdefaulttimeout
    runningpods=($(oc get pods -l name=ailibrary-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

test_ai_library

os::test::junit::declare_suite_end
