# ODH Argo

![ODH Argo Workflows version](https://img.shields.io/badge/ODH_Argo_version-v2.12.5-yellow.svg) <!-- v2.12.5 -->
![Upstream version](https://img.shields.io/github/v/release/argoproj/argo?label=Upstream%20release)

ODH Argo component installs Argo Workflows that is namespace bound and not cluster wide. There are two pods running after installation

1. Argo Server
2. Argo Controller

This Argo Workflows installation uses the "k8sapi" executor to work on Openshift.

### Folders

1. `cluster` folder contains all the cluster wide resources required to be installed by the operator before Argo can be deployed. It contains all `CustomResourceDefinitions` and `ClusterRoles` which aggregates permissions for those CRDs to admin/edit/view project roles.

2. There's only a single `base` folder within the `odhargo` folder. This `base` includes all installation yaml files to all necessary namespaced Argo resources.

### Argo Server

This installation creates a route to the Argo Workflows portal. To access the portal go to `Routes` and click on the `Argo Server` route.

### Installation

To install Argo Workflows add the following to the `kfctl` yaml file.

```yaml
- kustomizeConfig:
    repoRef:
      name: manifests
      path: odhargo/cluster
  name: odhargo-cluster
- kustomizeConfig:
    repoRef:
      name: manifests
      path: odhargo/odhargo
  name: odhargo
```

### Run a Workflow

To run an example workflow, you can use the portal UI to submit an [example workflow](odhargo/base/test-workflow.yaml) structured as:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
spec: ...
```

or submit it via [Argo Workflows CLI](https://github.com/argoproj/argo/releases):

```sh
argo submit odhargo/base/test-workflow.yaml
```

### Known issues

- Argo Workflows UI raises 2 "Forbidden" notifications on initial page load. This is just a cosmetic issue and doesn't effect functionality. [argoproj/argo#4885](https://github.com/argoproj/argo/issues/4885)
