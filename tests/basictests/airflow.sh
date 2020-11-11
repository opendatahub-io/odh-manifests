#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

AIRFLOWBASE_CR="${MY_DIR}/../resources/airflowbase.yaml"
AIRFLOWCLUSTER_CR="${MY_DIR}/../resources/airflowcluster.yaml"

os::test::junit::declare_suite_start "$MY_SCRIPT"


function create_airflow(){
  header "Creating AirflowBase and AirflowCluster"
  os::cmd::expect_success "oc create -f ${AIRFLOWBASE_CR}"
  os::cmd::expect_success "oc create -f ${AIRFLOWCLUSTER_CR}"
}

function test_routes(){
  header "Testing Flower and AirflowUI Routes"
  airflowuiroute=$(oc get route pc-cluster-airflowui -o jsonpath="{$.status.ingress[0].host}")
  flowerroute=$(oc get route pc-cluster-flower -o jsonpath="{$.status.ingress[0].host}")
  os::cmd::try_until_text "curl -k http://$airflowuiroute/admin/" "Airflow - DAGs"
  os::cmd::try_until_text "curl -k http://$flowerroute" "Flower"
}

function verify_airflow(){
  header "Verifying Pods for Airflow"
  os::cmd::try_until_text "oc get pods -l statefulset.kubernetes.io/pod-name=pc-base-nfs-0 --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "pc-base-nfs-0" $odhdefaulttimeout $odhdefaultinterval
  os::cmd::try_until_text "oc get pods -l statefulset.kubernetes.io/pod-name=pc-base-postgres-0 --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "pc-base-postgres-0" $odhdefaulttimeout $odhdefaultinterval
  os::cmd::try_until_text "oc get pods -l statefulset.kubernetes.io/pod-name=pc-cluster-airflowui-0 --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "pc-cluster-airflowui-0" $odhdefaulttimeout $odhdefaultinterval
  os::cmd::try_until_text "oc get pods -l statefulset.kubernetes.io/pod-name=pc-cluster-flower-0 --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "pc-cluster-flower-0" $odhdefaulttimeout $odhdefaultinterval
  os::cmd::try_until_text "oc get pods -l statefulset.kubernetes.io/pod-name=pc-cluster-redis-0 --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "pc-cluster-redis-0" $odhdefaulttimeout $odhdefaultinterval
  os::cmd::try_until_text "oc get pods -l statefulset.kubernetes.io/pod-name=pc-cluster-scheduler-0 --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "pc-cluster-scheduler-0" $odhdefaulttimeout $odhdefaultinterval
  os::cmd::try_until_text "oc get pods -l statefulset.kubernetes.io/pod-name=pc-cluster-worker-0 --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "pc-cluster-worker-0" $odhdefaulttimeout $odhdefaultinterval
  os::cmd::try_until_text "oc get pods -l statefulset.kubernetes.io/pod-name=pc-cluster-worker-1 --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "pc-cluster-worker-1" $odhdefaulttimeout $odhdefaultinterval
}

function delete_airflow(){
  header "Deleting Airflow Cluster"
  os::cmd::expect_success "oc delete -f ${AIRFLOWBASE_CR}"
  os::cmd::expect_success "oc delete -f ${AIRFLOWCLUSTER_CR}"
}

function test_airflow() {
    header "Testing Airflow installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get deployment airflow-on-k8s-operator-controller-manager" "airflow-on-k8s-operator-controller-manager" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l control-plane=controller-manager --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}'" "airflow-on-k8s-operator-controller-manager" $odhdefaulttimeout $odhdefaultinterval
    runningpods=($(oc get pods -l control-plane=controller-manager --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
    create_airflow
    echo "Sleeping for 2 min after creating airflow"
    sleep 2m
    verify_airflow
    test_routes
    delete_airflow
}

test_airflow

os::test::junit::declare_suite_end
