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
