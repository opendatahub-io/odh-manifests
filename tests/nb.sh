#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

os::test::junit::declare_suite_start "$MY_SCRIPT"

function getworker {
    python3 -c "import yaml; print(yaml.safe_load(open(\"$1\"))[\"worker\"][\"instances\"])"
}

function check_nb() {

    # if a single notebook server has been created (manually), we can check and see if it deployed spark
    cnt=($(oc get pod -l component=singleuser-server,app=jupyterhub -o jsonpath="{$.items[*].metadata.name}"))
    if [ "${#cnt[@]}" -gt 0 ]; then # there is at least one server pod

	# we've got a server, so find out what (if any) spark cluster the notebook container is expecting
	nm=$(oc get pod ${cnt[0]} -o jsonpath="{.spec.containers[?(@.name=='notebook')].env[?(@.name=='SPARK_CLUSTER')].value}")
	if [ -n "$nm" ]; then
	    
	    # okay we know it should use a configmap of the same name as the cluster
	    os::cmd::expect_success "oc get configmap $nm"

	    # messy but we're going to write the config yaml to a file
	    # and use python to extract values, since the config is just a string in the configmap
	    o=$(mktemp)
	    oc get configmap $nm -o jsonpath="{.data.config}" > $o

	    # check the number of workers (use a python function to read the file)
	    worker_cnt=$(getworker $o)

	    # make sure we've actually got pods
	    os::cmd::expect_success_and_not_text "oc get pod -l radanalytics.io/SparkCluster=$nm,radanalytics.io/podType=worker" "No resources found."

	    # check that the count matches
	    workers=($(oc get pod -l radanalytics.io/SparkCluster="$nm",radanalytics.io/podType=worker -o jsonpath="{$.items[*].metadata.name}"))
	    os::cmd::expect_success_and_text "echo ${#workers[@]}" "$worker_cnt"
	    
	    rm $o
	fi
    fi
}

check_nb

os::test::junit::declare_suite_end
