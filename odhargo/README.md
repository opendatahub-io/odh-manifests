# Argo 

Argo component installs Argo version 2.7 that is namespace bound and not cluster wide. There are two pods running after installation
1. Argo Server
2. Argo Controller

This Argo installation uses the "k8sapi" executor to work on Openshift.

### Folders
There is only one folder, `base`. This folder includes the installation yaml files to all necessary Argo resources that need to be installed

### Argo Portal

This installation creates a route to the Argo portal. To access the portal go to `Routes` and click on the `Argo Portal` route.


### Installation
To install Argo add the following to the `kfctl` yaml file.

```
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: odhargo
    name: odh-argo
```

### Run a Workflow
To run an example workflow, you can use the portal UI to run the example workflow, however the `serviceAccountName` has to be added to the workflow as shown below. We created this example `serviceAccount` as part of the installation to give basic permissions to a workflow. You can edit this `serviceAccount` and add more pemissions if your workflow requires that.
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
spec:
  serviceAccountName: argo-workflow
```
