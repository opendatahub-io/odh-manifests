# Basic opendatahub tests and how to use them

This test repository is meant to be used with the
test runner [located here](https://github.com/tmckayus/peak),
see the README.md there for complete information.

The intial tests here verify deployment of a KFDef instance

# Quick start

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
