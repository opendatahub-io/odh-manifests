IMAGE=odh-manifests-test
GIT_ORG=opendatahub-io
GIT_BRANCH=master
ODHPROJECT=opendatahub
OPENSHIFT_USER=
OPENSHIFT_PASS=
OPENSHIFT_LOGIN_PROVIDER=
SKIP_PODS_OUTPUT=
# Setting SKIP_INSTALL will let you run the tests against an ODH instance that is already setup
SKIP_INSTALL=
# Setting TESTS_REGEX will allow you to change which tests are going to be run
TESTS_REGEX=

all: test
test: build run clean

build:
	podman build -t $(IMAGE) --build-arg ORG=$(GIT_ORG) --build-arg BRANCH=$(GIT_BRANCH) .

run:
	mkdir -p `pwd`/screenshots/
	oc config view --flatten --minify > /tmp/tests-kubeconfig
	podman run -e SKIP_PODS_OUTPUT=$(SKIP_PODS_OUTPUT) -e SKIP_INSTALL=$(SKIP_INSTALL) -e TESTS_REGEX=$(TESTS_REGEX) -e ODHPROJECT=$(ODHPROJECT) \
		-e OPENSHIFT_USER="$(OPENSHIFT_USER)" -e OPENSHIFT_PASS="$(OPENSHIFT_PASS)" -e OPENSHIFT_LOGIN_PROVIDER=$(OPENSHIFT_LOGIN_PROVIDER) \
		-it -v `pwd`/screenshots/:/tmp/screenshots:z -v /tmp/tests-kubeconfig:/tmp/kubeconfig:z $(IMAGE)

clean:
	oc delete -n $(ODHPROJECT) kfdef opendatahub || true
	oc delete project $(ODHPROJECT) || echo -e "\n\n==> If the project deletion failed, you can try to use this script to force it: https://raw.githubusercontent.com/jefferyb/useful-scripts/master/openshift/force-delete-openshift-project\n\n"
	#Clean up openshift-operators namespace
	oc get csv -n openshift-operators -o name | grep strimzi-cluster-operator | xargs oc delete -n openshift-operators || true
	oc get csv -n openshift-operators -o name | grep opendatahub-operator | xargs oc delete -n openshift-operators || true
	oc delete subscription -n openshift-operators -l peak.test.subscription=opendatahub-operator
	oc get mutatingwebhookconfiguration -o name | grep seldon | grep $(ODHPROJECT) | xargs oc delete || true
	oc get mutatingwebhookconfiguration -o name | grep katib | grep $(ODHPROJECT) | xargs oc delete || true
	oc get validatingwebhookconfiguration -o name | grep seldon | grep $(ODHPROJECT) | xargs oc delete || true
	oc get validatingwebhookconfiguration -o name | grep katib | grep $(ODHPROJECT) | xargs oc delete || true
