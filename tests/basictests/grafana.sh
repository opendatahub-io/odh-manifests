#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function test_grafana_functionality() {
    # Make sure that route is active and that the app responds as expected
    os::cmd::try_until_text "oc get route grafana-route -o jsonpath='{$.status.ingress[0].conditions[0].type}'" "Admitted" $odhdefaulttimeout $odhdefaultinterval
    uiroute=$(oc get route grafana-route -o jsonpath="{$.status.ingress[0].host}")
    os::cmd::try_until_text "curl -k https://$uiroute" "Grafana" $odhdefaulttimeout $odhdefaultinterval
    # Use the search api make sure that our dashboard is indeed there
    os::cmd::try_until_text "curl -k https://$uiroute/api/search?query=Kafka | jq '.[].url'" "kafka-overview" $odhdefaulttimeout $odhdefaultinterval
    dashboardurl=$(curl -k https://$uiroute/api/search?query=Kafka | jq '.[].url' | tr -d '\"')
    os::cmd::expect_success "curl -k https://${uiroute}${dashboardurl}"
}

function test_grafana() {
    header "Testing ODH Grafana installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get deployment grafana-operator" "grafana-operator" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l name=grafana-operator --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "grafana-operator" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l name=grafana-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    os::cmd::try_until_text "oc get grafanadashboard" "odh-kafka" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get grafanadatasource" "odh-datasource" $odhdefaulttimeout $odhdefaultinterval
}

test_grafana
test_grafana_functionality

os::test::junit::declare_suite_end
