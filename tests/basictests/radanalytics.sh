#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

SPARK_CLUSTER_CR="${MY_DIR}/../resources/radanalytics.sparkcluster.yaml"
SPARK_APPLICATION_CR="${MY_DIR}/../resources/radanalytics.sparkapplication.yaml"

function verify_spark_operator_install() {
    header "Testing Radanalytics Spark Operator installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::expect_success_and_text "oc get deployment spark-operator" "spark-operator"
    runningpods=($(oc get pods -l app.kubernetes.io/name=radanalytics-spark-operator --field-selector="status.phase=Running" -o jsonpath="{$.items[*].metadata.name}"))
    os::cmd::expect_success_and_text "echo ${#runningpods[@]}" "1"
}

function create_spark_cluster() {
    header "Create Radanalytics Spark Cluster"
    os::cmd::expect_success "oc create -f ${SPARK_CLUSTER_CR}"
    os::cmd::try_until_not_text "oc get sparkcluster test-spark-cluster" "not found"
    os::cmd::try_until_not_text "oc get pod -l radanalytics.io/deployment=test-spark-cluster-m --field-selector='status.phase=Running'" "No resources found"
    os::cmd::try_until_not_text "oc get pod -l radanalytics.io/deployment=test-spark-cluster-w --field-selector='status.phase=Running'" "No resources found"
}

function verify_spark_cluster() {
    header "Test SparkCluster by calculating the value of Pi"
    spark_master_pod=$(oc get pod -l radanalytics.io/deployment=test-spark-cluster-m -o jsonpath='{$.items[*].metadata.name}')
    spark_example_jar=$(oc exec $spark_master_pod -- find /opt/spark/examples/jars -type f -name 'spark-examples*jar' -printf "%f")
    os::cmd::try_until_text "\
      oc exec $spark_master_pod -- \
      /opt/spark/bin/spark-submit \
      --class org.apache.spark.examples.SparkPi \
      --num-executors 1 \
      --driver-memory 512m \
      --executor-memory 512m \
      --executor-cores 1 \
      /opt/spark/examples/jars/$spark_example_jar 10" "Pi is roughly 3.14"
}
function delete_spark_cluster() {
    header "The Spark Operator should delete the SparkCluster pods"
    os::cmd::expect_success "oc delete -f ${SPARK_CLUSTER_CR}"
    os::cmd::try_until_text "oc get sparkcluster test-spark-cluster" "not found"
    os::cmd::try_until_text "oc get pod -l radanalytics.io/deployment=test-spark-cluster-m" "No resources found"
    os::cmd::try_until_text "oc get pod -l radanalytics.io/deployment=test-spark-cluster-w" "No resources found"
}

function create_spark_application() {
    header "Create Radanalytics SparkApplication"
    os::cmd::expect_success "oc create -f ${SPARK_APPLICATION_CR}"
    os::cmd::try_until_not_text "oc get sparkapplication test-spark-app" "not found"
    os::cmd::try_until_not_text "oc get pod -l radanalytics.io/kind=SparkApplication" "not found"
}

function delete_spark_application() {
    header "Delete Radanalytics SparkApplication"
    os::cmd::expect_success "oc delete -f ${SPARK_APPLICATION_CR}"
    os::cmd::try_until_text "oc get sparkapplication test-spark-app" "not found"
}

function test_radanalytics_functionality() {
    header "Testing Radanalytics functionality"
    os::cmd::expect_success "oc project ${ODHPROJECT}"

    verify_spark_operator_install

    create_spark_cluster
    verify_spark_cluster
    delete_spark_cluster

    create_spark_application
    delete_spark_application
}

test_radanalytics_functionality

os::test::junit::declare_suite_end
