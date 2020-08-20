# Running containerized tests

Running the tests this way assumes that you have an active kubeadmin login
on the cluster that you want to run the tests against and that you have podman
installed.  (If you prefer docker, you can edit the Makefile to replace podman
with docker).

Run the following:

```
cd tests
make build
make run
```

## Cleaning up after your test run (optional)

Only run the following if you want to eliminate your Open Data Hub installation.

To cleanup the Open Data Hub installation after a test run, you can run `make clean`.
Running `make clean` **will wipe your Open Data Hub installation** and delete the project.


## Customizing test behavior

Without changes, the test image will run `$HOME/peak/installandtest.sh` which
handles setting up the opendatahub-operator and then creating the KfDef found in
`tests/setup/kfctl_openshift.yaml`.  If you want to modify your test run, you
might want to change those files to get the behavior that you're looking for.
After you make changes, you will need to rebuild the test image with `make build`.

If you'd like to run the tests against an instance that already has Open Data Hub installed,
you set `SKIP_INSTALL=true` and that will cause the test run
to skip the installation process and will only run the tests.  example: `make run SKIP_INSTALL=true`

If you'd like to run a single test instead of all tests, you can
set the TESTS_REGEX variable `TESTS_REGEX=<name of the test to run>`.  That will
only run the test that you specify instead of all of the tests.  example: `make run TESTS_REGEX=grafana`

For other possible configurations, you can look in the Makefile.  There are a set of
variables at the top that you could change to meet the needs of your particular test run.

# Running tests manually

Manual running of the tests relies on the test
runner [located here](https://github.com/tmckayus/peak).
See the README.md there for more detailed information on how it works.

Note when running on a **mac** you may need to do the following:

```
brew install coreutils
ln -s /usr/local/bin/greadlink /usr/local/bin/readlink
```

Make sure you have an OpenShift login, then do the following:

```bash
git clone https://github.com/tmckayus/peak
cd peak
git submodule update --init
echo opendatahub-kubeflow nil https://github.com/opendatahub-io/odh-manifests > my-list
./setup.sh -t my-list
./run.sh operator-tests/opendatahub-kubeflow/tests/basictests
```

Note, if you're looking to test another repo and/or branch, you can change the "echo" command from above to something of the following form where "your branch" is optional:

```
echo opendatahub-kubeflow nil <your repo> <your branch> > my-list
```

If your installation is not in the opendatahub project, you will need to modify
the export line in tests/util to set the value of ODHPROJECT to match name of the project you are using.

You can run tests individually by passing a substring to run.sh to match:

```bash
./run.sh ailibrary.sh
```

# Basic test

These tests are in the basictests directory.  This set of tests assumes that you have opendatahub (Kubeflow-based) isntalled.  It then goes through each module and tests
to be sure that the expected pods are all in the running state.  This is meant to be the barebones basic smoke tests for an installation.
The steps to run this test are:

* Run the tests

  ```bash
  ./run.sh tests/basictests
  ```
